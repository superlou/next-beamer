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
from dotenv_light import load_dotenv

tz = get_localzone()


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
            'location': shorten_location(sanitize(location))
        }

        sessions_list.append(data)

    with open(catalog_file, 'w') as out_file:
        json.dump(sessions_list, out_file, sort_keys=True, indent=4)

    print('Done.')


def save_json(data, filename, date_format):
    def custom_serializer(x):
        if isinstance(x, datetime.datetime):
            return x.astimezone(tz).strftime(date_format)
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


def shorten_location(location):
    name_map = {
        "Tabletop Gaming": "Tabletop"
    }
    location = name_map.get(location, location)

    """ Extract the ACCC room number from a string like "303 - Panel 1". """
    shorter = location.split('-')[0].strip()
    return shorter


def session_is_all_day(s, now):
    all_day_threshold = datetime.timedelta(hours=4.5)
    return ((s['finish'] - s['start']) > all_day_threshold and
           s['start'].date() == now.date())


def session_is_running(s, now):
    return now >= s['start'] and now < s['finish']


def session_started(s, now):
    return now >= s['start']


def session_finished(s, now):
    return now >= s['finish']


def get_now_and_soon(sessions, now):
    sessions = [s for s in sessions if not session_is_all_day(s, now)]

    happening_now = [s for s in sessions if session_is_running(s, now)]

    soon_cutoff = datetime.timedelta(hours=2)
    soon = [s for s in sessions
            if s['start'] > now and (s['start'] - now) < soon_cutoff]

    return happening_now, soon


def get_all_day(sessions, now, date_format):
    sessions = [s for s in sessions if session_is_all_day(s, now)]
    sessions = sorted(sessions, key=lambda k: k['name'])

    for session in sessions:
        if session_is_running(session, now):
            session['time1'] = 'Closes at'
            session['time2'] = session['finish'].astimezone(tz).strftime(date_format)
            session['running'] = True
        elif not session_started(session, now):
            session['time1'] = 'Opens at'
            session['time2'] = session['start'].astimezone(tz).strftime(date_format)
            session['running'] = False
        elif session_finished(session, now):
            session['time1'] = 'Closed'
            session['time2'] = 'for today'
            session['running'] = False

    return {
        'font': 'Gudea-Bold.ttf',
        'events': sessions
    }


def add_metadata(events, title, duration, font):
    return {
        'duration': duration,
        'title': title,
        'font': font,
        'events': events
    }


def update(now, font, date_format):
    sessions = load_guidebook_json('guidebook.json')
    sessions = sorted(sessions, key=lambda k: (k['start'], k['location']))
    on_now, on_soon = get_now_and_soon(sessions, now)
    all_day = get_all_day(sessions, now, date_format)

    on_now = add_metadata(on_now, 'HAPPENING NOW', 15, font)
    on_soon = add_metadata(on_soon, 'COMING UP', 15, font)

    save_json(on_now, 'data_happening_now.json', date_format)
    save_json(on_soon, 'data_happening_soon.json', date_format)
    save_json(all_day, 'data_all_day.json', date_format)


if __name__ == '__main__':
    load_dotenv()

    if os.name == "nt":
        # Format codes for Windows are different
        DATE_FORMAT = "%#I:%M %p"
    else:
        DATE_FORMAT = "%-I:%M %p"

    if len(sys.argv) > 1:
        if sys.argv[1] in ['--pull', '-p']:
            pull_from_guidebook('195964', 'guidebook.json')
            sys.exit()

    while 1:
        try:
            now_str = json.load(open("data_services.json"))["config"]["now"]
            now = dateutil.parser.parse(now_str)
        except Exception as e:
            now = datetime.datetime.now(datetime.timezone.utc)

        try:
            update(now, 'Gudea-Bold.ttf', DATE_FORMAT)
        except Exception as e:
            print(traceback.format_exc())

        sleep(1)
