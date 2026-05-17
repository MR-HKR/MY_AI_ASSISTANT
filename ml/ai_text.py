import joblib



def load_model():
    data = joblib.load('ml/text_ai.pkl')
    return data['vectorizer'], data['model']

vec, model = load_model()

def txt_detect(txt):
    return model.predict(vec.transform([txt]))[0]
 