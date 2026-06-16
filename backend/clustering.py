def get_cluster_weight(title, description, category):

    text = (title + " " + description).lower()

    # Network Cluster
    network_keywords = [
        "wifi",
        "internet",
        "network",
        "slow",
        "connection"
    ]

    # Food Cluster
    food_keywords = [
        "food",
        "meal",
        "canteen",
        "cafe",
        "burger",
        "drink"
    ]

    # Education Cluster
    education_keywords = [
        "teacher",
        "class",
        "book",
        "lab",
        "assignment",
        "lecture"
    ]

    cluster_weight = 1

    # Network cluster matching
    for word in network_keywords:
        if word in text:
            cluster_weight += 2
            break

    # Food cluster matching
    for word in food_keywords:
        if word in text:
            cluster_weight += 2
            break

    # Education cluster matching
    for word in education_keywords:
        if word in text:
            cluster_weight += 2
            break

    # Category bonus
    if category.lower() in ["network", "food", "education"]:
        cluster_weight += 1

    return cluster_weight