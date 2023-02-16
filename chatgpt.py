import openai
from flask import Flask, jsonify, request, Response

# Add your OpenAI API key
openai.api_key = "PLACE-YOUR-OPENAI-API-KEY-HERE"

def generate_text(prompt):
    completions = openai.Completion.create(
        engine="text-davinci-002",
        prompt=prompt,
        max_tokens=1024,
        n=1,
        stop=None,
        temperature=0.7,
    )

    message = completions.choices[0].text
    return message.strip()

app = Flask(__name__)

@app.route('/<string:query>')
def chat(query):
    return (generate_text(query))

# main function
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug = True)
