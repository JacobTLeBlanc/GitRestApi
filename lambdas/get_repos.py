import json
import logging
import urllib.request as request
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

TOKEN = os.getenv('GIT_TOKEN')

def get_repos(user):
    """
    Gets repos for the given user

    Params
    -------
    user
        user to get repos from

    Returns
    -------
    json
        a json object representing a list of (public) repositories
    """

    logger.info("Getting repos from " + user)

    response = request.urlopen(
            request.Request(
                url='https://api.github.com/users/' + user + '/repos',
                headers={
                    'Accept': 'application/json',
                    'Authorization': TOKEN
                },
                method='GET'
            ),
            timeout=5
        )

    return json.loads(response.read())

def lambda_handler(event, context):

    user = event['pathParameters']['user']

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(get_repos(user))
    }