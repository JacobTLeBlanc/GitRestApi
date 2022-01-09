import json
import urllib.request as request

def get_repos():
    """
    Gets repos for the configured user

    Returns
    -------
    json
        a json object representing a list of repositories
    """

    response = request.urlopen(
            request.Request(
                url='https://api.github.com/users/jacobtleblanc/repos',
                headers={'Accept': 'application/json'},
                method='GET'
            ),
            timeout=5
        )

    return json.loads(response.read())

def lambda_handler(event, context):

    return {
        'statusCode': 200,
        'body': json.dumps(get_repos())
    }