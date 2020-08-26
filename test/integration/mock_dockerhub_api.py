from flask import Flask, request, abort
import json
from os import path

app = Flask(__name__)

# testing paths:
# curl 192.168.99.201:5000/v2/repositories/birdhouse/finch/tags
# curl 192.168.99.201:5000/v2/repositories/pavics/weaver/tags



@app.route('/v2/repositories/<dockerhub_project>/<dockerhub_repo>/tags', methods=['GET'])
def get_tags(dockerhub_project, dockerhub_repo):
    filepath = "./mock_data" + "/" + dockerhub_project + "_" + dockerhub_repo

    if path.exists(filepath):
        f = open(filepath)
        data = json.load(f)
    else:
        abort(404)
    
    return data

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)