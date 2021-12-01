import sublime_plugin
import urllib.request
import webbrowser
import datetime

class AdventOfCodeGetDataCommand(sublime_plugin.TextCommand):
    def run(self, edit, year, day):
          webbrowser.open('https://adventofcode.com/'+year+'/day/'+day);
          req = urllib.request.Request('http://adventofcode.com/'+year+'/day/'+day+'/input', None, {'cookie': 'session=<insert session ID here>'});
          self.view.insert(edit, 0, urllib.request.urlopen(req).read().decode('utf-8')[:-1]);
    def input(self, args):
        if 'year' not in args:
          return YearInputHandler();
        elif 'day' not in args:
          return DayInputHandler();

class YearInputHandler(sublime_plugin.ListInputHandler):
    def list_items(self):
        years = [];
        for year in range(datetime.datetime.now().year, 2014, -1):
            years.append(str(year));
        return years;
    def placeholder(self):
        return 'Year';

class DayInputHandler(sublime_plugin.ListInputHandler):
    def list_items(self):
        days = [];
        soon = datetime.datetime.now() + datetime.timedelta(minutes=15);
        for day in range(soon.day, 0, -1):
            days.append(str(day));
        for day in range(soon.day+1, 26, 1):
            days.append(str(day));
        return days;
    def placeholder(self):
        return 'Day';
