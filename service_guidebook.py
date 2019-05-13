#!/usr/bin/python3
import os
import sys
import json
import dateutil.parser
import datetime
import traceback
from tzlocal import get_localzone
from time import sleep, time
from guidebook import api_requestor


def request_paginated(api_requestor, method, api_url):
    response = api_requestor.request(method, api_url)
    results = response['results']

    while 'next' in response and response['next']:
        response = api_requestor.request(method, response['next'])
        results += response['results']

    return results


def sanitize(text):
    return text.replace(' \u2013', ',')


def pull_from_guidebook(guide_id, catalog_file):
    api_key = os.environ.get('GUIDEBOOK_API_KEY')
    if not api_key:
        print('GUIDEBOOK_API_KEY environment variable not set!')
        print('API key available at https://builder.guidebook.com/#/account/api/')
        sys.exit()

    client = api_requestor.APIRequestor(api_key)

    print('Fetching sessions...')
    url = ('https://builder.guidebook.com/open-api/v1/'
           'sessions/?guide={}&ordering=start_time').format(guide_id)
    sessions = request_paginated(client, 'get', url)

    print('Fetching locations...')
    url = 'https://builder.guidebook.com/open-api/v1/locations/'
    locations = request_paginated(client, 'get', url)

    location_name_map = {
        location['id']: location['name'] for location in locations
    }

    print('Combining...')
    sessions_list = []

    for session in sessions:
        if len(session['locations']) > 0:
            location = location_name_map.get(session['locations'][0], '')
        else:
            location = ''

        data = {
            'name': sanitize(session['name']),
            'start': session['start_time'],
            'finish': session['end_time'],
            'location': sanitize(location)
        }

        sessions_list.append(data)

    with open(catalog_file, 'w') as out_file:
        json.dump(sessions_list, out_file, sort_keys=True, indent=4)

    print('Done.')


def save_json(data, filename, date_format):
    def custom_serializer(x):
        if isinstance(x, datetime.datetime):
            return x.astimezone(get_localzone()).strftime(date_format)
        raise TypeError("Unknown type")

    json_string = json.dumps(data, sort_keys=True, indent=4,
                             default=custom_serializer)

    try:
        with open(filename) as out_file:
            if json_string == out_file.read():
                return
    except Exception:
        pass

    with open(filename, 'w') as out_file:
        out_file.write(json_string)


def load_guidebook_json(filename):
    raw = json.load(open(filename))
    sessions = []
    for session in raw:
        try:
            sessions.append({
                'start': dateutil.parser.parse(session['start']),
                'finish': dateutil.parser.parse(session['finish']),
                'name': session['name'],
                'location': session['location']
            })
        except Exception:
            pass

    return sessions


def get_now_and_soon(sessions, now=None):
    if now is None:
        now = datetime.datetime.now(datetime.timezone.utc)

    sessions = sorted(sessions, key=lambda k: (k['start'], k['location']))
    happening_now = [s for s in sessions if now >= s['start'] and now < s['finish']]

    soon_cutoff = datetime.timedelta(hours=2)
    soon = [s for s in sessions if s['start'] > now and (s['start'] - now) < soon_cutoff]

    return happening_now, soon


def add_metadata(events, title, duration, font):
    return {
        'duration': duration,
        'title': title,
        'font': font,
        'events': events
    }


if __name__ == '__main__':
    now = None

    if len(sys.argv) > 1:
        if sys.argv[1] in ['--pull', '-p']:
            pull_from_guidebook('159116', 'guidebook.json')
            sys.exit()
        else:
            now = dateutil.parser.parse(sys.argv[1])

    font = 'RobotoCondensed-Regular.ttf'

    # Only use for testing
    #now = dateutil.parser.parse("2018-06-08T12:46:00.000000-0400")

    while 1:
        try:
            sessions = load_guidebook_json('guidebook.json')
            on_now, on_soon = get_now_and_soon(sessions, now)
            on_now = add_metadata(on_now, 'HAPPENING NOW', 15, font)
            on_soon = add_metadata(on_soon, 'COMING UP', 15, font)
            save_json(on_now, 'data_happening_now2.json', date_format="%-I:%M %p")
            save_json(on_soon, 'data_happening_soon2.json', date_format="%-I:%M %p")
        except Exception as e:
            print(traceback.format_exc())

        sleep(1)
