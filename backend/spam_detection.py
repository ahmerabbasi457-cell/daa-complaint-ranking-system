def detect_spam(title, description, likes):

    spam_score = 0

    title_lower = title.lower()
    description_lower = description.lower()

    # Rule 1: Too many likes
    if likes > 100:
        spam_score += 1

    # Rule 2: Repeated words in title
    words = title_lower.split()

    if len(words) != len(set(words)):
        spam_score += 1

    # Rule 3: Very short description
    if len(description.strip()) < 10:
        spam_score += 1

    # Rule 4: Spam keywords
    spam_keywords = [
        "spam",
        "fake",
        "hack",
        "test test",
        "asdf",
        "123123"
    ]

    for keyword in spam_keywords:
        if keyword in title_lower or keyword in description_lower:
            spam_score += 1

    # Rule 5: Too many repeated characters
    if "!!!!!" in description or "?????" in description:
        spam_score += 1

    # Final Decision
    if spam_score >= 1:
        return 1

    return 0