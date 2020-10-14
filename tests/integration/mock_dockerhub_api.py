from flask import Flask, request, abort
import json
from os import path

app = Flask(__name__)

# testing paths:
# curl 192.168.99.201:5555/v2/repositories/birdhouse/finch/tags
# curl 192.168.99.201:5555/v2/repositories/pavics/weaver/tags
# curl -XPOST localhost:5555/pavics/weaver/1.13.2-worker


BIRDHOUSE_FINCH_DATA = json.load(open("./mock_data/birdhouse_finch"))
PAVICS_WEAVER_DATA = json.load(open("./mock_data/pavics_weaver"))

dockerhub_mock_data = {
    "birdhouse_finch" : BIRDHOUSE_FINCH_DATA,
    "pavics_weaver" : PAVICS_WEAVER_DATA
}


@app.route('/v2/repositories/<dockerhub_project>/<dockerhub_repo>/tags', methods=['GET'])
def get_tags(dockerhub_project, dockerhub_repo):
    data_key = dockerhub_project + "_" + dockerhub_repo

    if data_key in dockerhub_mock_data:
        data = dockerhub_mock_data[data_key]
    else:
        data = {
            "results": []
        }
    
    return data


@app.route('/<dockerhub_project>/<dockerhub_repo>/<tagname>', methods=['POST'])
def post_tag(dockerhub_project, dockerhub_repo, tagname):
    data_key = dockerhub_project + "_" + dockerhub_repo

    if data_key not in dockerhub_mock_data:
        dockerhub_mock_data[data_key] = {
            "results": []
        }

    dockerhub_mock_data[data_key]["results"].insert(0, {
      "name": tagname
    })

    return "pushed tag " + dockerhub_project + "/" + dockerhub_repo + ":" + tagname + " on DockerHub\n"

@app.route('/reset/<token>', methods=['POST'])
def post_reset(token):
    if token == 'token1234':
        global dockerhub_mock_data
        dockerhub_mock_data = {
            "birdhouse_finch" : BIRDHOUSE_FINCH_DATA,
            "pavics_weaver" : PAVICS_WEAVER_DATA
        }

    return "resetted dockerhub tags\n"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5555)