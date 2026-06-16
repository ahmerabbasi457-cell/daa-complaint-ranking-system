import time

def calculate_score(
    likes,
    timestamp,
    credibility,
    spam_score,
    cluster_weight
):

    current_time = time.time()

    # Time decay
    time_diff = current_time - float(timestamp)

    recency = max(0, 10000 - time_diff) / 1000

    # Final weighted score
    score = (
        (2.5 * likes)
        + (4.0 * recency)
        + (1.5 * credibility)
        + (2.0 * cluster_weight)
        - (3.0 * spam_score)
    )

    return score