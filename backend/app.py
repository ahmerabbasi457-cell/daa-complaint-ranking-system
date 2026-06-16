from flask import Flask, request, jsonify
from flask_cors import CORS
from database import initialize_database, get_connection
from ranking import calculate_score
from topk_heap import TopKHeap
from spam_detection import detect_spam
from clustering import get_cluster_weight
import time

app = Flask(__name__)
CORS(app)

# Initialize database
initialize_database()

@app.route('/')
def home():
    return {
        "message": "Dynamic Top-K Complaint Ranking System Backend Running"
    }

# -----------------------------
# SUBMIT COMPLAINT
# -----------------------------
@app.route('/submit-complaint', methods=['POST'])
def submit_complaint():

    data = request.get_json()

    title = data.get('title')
    description = data.get('description')
    category = data.get('category')
    urgency = data.get('urgency')
    location = data.get('location')

    # Initial likes
    likes = 0

    # Detect spam
    spam_score = detect_spam(
        title=title,
        description=description,
        likes=likes
    )

    # Current timestamp
    timestamp = time.time()

    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        INSERT INTO complaints
        (
            title,
            description,
            category,
            urgency,
            location,
            created_at,
            spam_score
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        title,
        description,
        category,
        urgency,
        location,
        timestamp,
        spam_score
    ))

    connection.commit()
    connection.close()

    return jsonify({
        "message": "Complaint submitted successfully",
        "spam_score": spam_score
    })

# -----------------------------
# GET TOP-K COMPLAINTS
# -----------------------------
@app.route('/get-complaints', methods=['GET'])
def get_complaints():

    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM complaints")
    rows = cursor.fetchall()

    # Top-K Value
    K = 5

    # Min Heap
    heap = TopKHeap(K)

    for row in rows:

        raw_timestamp = row["created_at"]

        try:
            timestamp = float(raw_timestamp)
        except:
            timestamp = time.time()

        # Clustering Weight
        cluster_weight = get_cluster_weight(
            title=row["title"],
            description=row["description"],
            category=row["category"]
        )

        # Final Score Calculation
        score = calculate_score(
            likes=row["likes"],
            timestamp=timestamp,
            credibility=1.0,
            spam_score=row["spam_score"],
            cluster_weight=cluster_weight
        )

        complaint = {
            "id": row["id"],
            "title": row["title"],
            "description": row["description"],
            "category": row["category"],
            "urgency": row["urgency"],
            "location": row["location"],
            "likes": row["likes"],
            "spam_score": row["spam_score"],
            "cluster_weight": cluster_weight,
            "score": score,
            "created_at": timestamp
        }

        # Add to Top-K Heap
        heap.add(complaint)

    complaints = heap.get_topk()

    connection.close()

    return jsonify({
        "complaints": complaints
    })
# -----------------------------
# LIKE COMPLAINT
# -----------------------------
@app.route('/like-complaint/<int:complaint_id>', methods=['POST'])
def like_complaint(complaint_id):

    connection = get_connection()
    cursor = connection.cursor()

    # Increase likes by 1
    cursor.execute("""
        UPDATE complaints
        SET likes = likes + 1
        WHERE id = ?
    """, (complaint_id,))

    connection.commit()

    # Get updated likes
    cursor.execute("""
        SELECT likes FROM complaints
        WHERE id = ?
    """, (complaint_id,))

    updated_likes = cursor.fetchone()["likes"]

    connection.close()

    return jsonify({
        "message": "Complaint liked successfully",
        "likes": updated_likes
    })

# -----------------------------
# RUN SERVER
# -----------------------------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)