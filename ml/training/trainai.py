from sklearn.feature_extraction.text import CountVectorizer


from sklearn.naive_bayes import MultinomialNB


import joblib

# Initialize lists
a = []
b = []

# Open your file (replace 'data.txt' with your filename)
with open('ml/training/texttotrain.txt', 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()  # remove whitespace and newline
        if not line or ':' not in line:
            continue  # skip empty lines or malformed lines
        left, right = line.split(':', 1)  # split at the first colon
        a.append(left.strip())
        b.append(right.strip())


vec = CountVectorizer()
vect = vec.fit_transform(a)

model = MultinomialNB()
model.fit(vect,b)




joblib.dump(
    {
        "vectorizer": vec,
        "model": model
    },
    'ml/text_ai.pkl'
)

print("ai training complete")

