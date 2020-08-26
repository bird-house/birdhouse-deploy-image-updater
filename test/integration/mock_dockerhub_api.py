from flask import Flask, request
import json

app = Flask(__name__)


BIRDHOUSE_FINCH_MOCK="mock_data/birdhouse_finch"
PAVICS_WEAVER_MOCK="mock_data/pavics_weaver"


@app.route('/v2/repositories/<dockerhub_repo>/tags', methods=['POST'])
def get_tags(dockerhub_repo):
    print(dockerhub_repo)


    data = json.load(json_file)
    
    return "ok"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)