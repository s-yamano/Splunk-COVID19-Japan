#!/usr/bin/env python3
# coding: utf-8

import sys
import os
from optparse import OptionParser

try:
    for d in ['.', '..']:
        privlib_path = os.path.join(os.path.dirname(__file__), d, "lib")
        if os.path.isdir(privlib_path):
            sys.path.insert(0, privlib_path)
            break
except NameError as e:
    pass

import requests
from bs4 import BeautifulSoup
import csv
import datetime

class Base_COVID19_Japan():
    # Japan COVID-19 Coronavirus Tracker
#    Covid19_Japan_Tracker_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRri4r42DHwMHePjJfYN-qEWhGvKeOQullBtEzfle15i-xAsm9ZgV8oMxQNhPRO1CId39BPnn1IO5YO/pubhtml"
    Covid19_Japan_Tracker_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRj0RcpTglCmtDVP1RRx21ZwteYU2Y_8JExoeIVbMG1onsmHHah3DwI2HwunY8FOU3eqme82th_hYWF/pubhtml"

    Covid19_Japan_Tracker_File_Prefix = "Japan_COVID-19_Coronavirus_Tracker"

    Covid19_Japan_Tracker_Sheets = {
        "Patient Data": {
            "gid": "0",
            "csvfile": "Patient_Data.csv",
            "make_DictListFunc": None,
            "end_index": 5,
        },
        "Tokyo": {
            "gid": "1167478583",
            "csvfile": "Tokyo.csv",
            "make_DictListFunc": None,
            "end_index": 4,
        },
        "Osaka": {
            "gid": "1062145453",
            "csvfile": "Osaka.csv",
            "make_DictListFunc": None,
            "end_index": 5,
        },
        "Aichi": {
            "gid": "1707816451",
            "csvfile": "Aichi.csv",
            "make_DictListFunc": None,
            "end_index": 4,
        },
        "Kanagawa": {
            "gid": "636371782",
            "csvfile": "Kanagawa.csv",
            "make_DictListFunc": None,
            "end_index": 4,
        },
        "Chiba": {
            "gid": "",
            "csvfile": "Chiba.csv",
            "make_DictListFunc": None,
            "end_index": 4,
        },
        "Prefecture Data": {
            "gid": "1399411442",
            "csvfile": "Prefecture_Data.csv",
            "make_DictListFunc": None,
            "end_index": 0,
        },
        "Sum By Day": {
            "gid": "211530313",
            "csvfile": "Sum_By_Day.csv",
            "make_DictListFunc": None,
            "end_index": 0,
        },
        "Last Updated": {
            "gid": "614137682",
            "csvfile": "Last_Updated.csv",
            "make_DictListFunc": None,
            "end_index": 0,
        },
        "Aggregates": {
            "gid": "1403721638",
            "csvfile": "Aggregates.csv",
            "make_DictList": None,
            "end_index": False,
        },
        "NHK": {
            "gid": "149956111",
            "csvfile": "NHK.csv",
            "make_DictListFunc": None,
            "end_index": 4,
        },
        "MHLW": {
            "gid": "149956111",
            "csvfile": "MHLW.csv",
            "make_DictListFunc": None,
            "end_index": False,
        },
        "Diamond Princess Sum By Day": {
            "gid": "2061808889",
            "csvfile": "Diamond_Princess_Sum_By_Day.csv",
            "make_DictListFunc": None,
            "end_index": 0,
        },
        "Diamond Princess Patient Data": {
            "gid": "392533480",
            "csvfile": "Diamond_Princess_Patient_Data.csv",
            "make_DictListFunc": None,
            "end_index": 2,
        },
        "Patient Statuses": {
            "gid": "1043373537",
            "csvfile": "Patient_Statuses.csv",
            "make_DictListFunc": None,
            "end_index": 0,
        },
        "Tokyo Counts": {
            "gid": "1747653987",
            "csvfile": "Tokyo_Counts.csv",
            "make_DictListFunc": None,
            "end_index": 0,
        },
    }
    _sheets = Covid19_Japan_Tracker_Sheets
    _target = None
    _res = None
    _bs = None
    _header = None
    _data = None
    _acquisition_time = None
    
    def __init__(self, sheet_name="Patient Data"):
        if sheet_name not in self.Covid19_Japan_Tracker_Sheets:
            raise ValueError(target + " is not in the Sheets.")
        
        self._acquisition_time = datetime.datetime.now()
        self._sheet_name = sheet_name
        self._target = self._sheets[sheet_name]
        self._target_url = self._get_URL()
        
        try:
            self._res = requests.get(self._target_url, timeout=(30.0, 60.0))
        except (requests.excetions.Timeout, ConnectionError) as e:
            raise e("Session Timeout")

        self._bs = BeautifulSoup(self._res.text, "html5lib")


    def _get_URL(self):
        return self.Covid19_Japan_Tracker_URL + '?gid=' + self._target["gid"]


    def _make_DictList(self):
        pass


    def _get_row_contents(self, row, header):
        tds = row.find_all("td")
        end_index = self._target["end_index"]
        if end_index is not False and len(tds[end_index].contents) == 0:
            return None
        content = { "_acquisition_time": self._acquisition_time.strftime("%Y/%m/%d %H:%M:%S -0900") }
        for num, td in enumerate(tds):
            if len(td.contents) == 0:
                tdc = ""
            else:
                if td.div is not None: # sometime content has a "div" tag
                    tdc_text = str(td.div.contents[0])
                else:
                    tdc_text = str(td.contents[0])
                tdc = tdc_text.replace("&amp;", "&")
            content[header[num+1]] = tdc
        return content

    
    def get_default_CSV_filename(self):
        return self.Covid19_Japan_Tracker_File_Prefix + '-' + self._target["csvfile"]
    
    def writeCSV(self, csv_file=None):
        if csv_file is None:
            raise ValueError("CSV Filename is required.")

        with open(csv_file, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=self._header, quoting=csv.QUOTE_ALL)
            writer.writeheader()
            writer.writerows(self._data)

    @classmethod
    def get_sheetnames(self):
        return list(self.Covid19_Japan_Tracker_Sheets)


class COVID19_Japan_Common(Base_COVID19_Japan):
    def __init__(self, sheet_name=None):
        self._target_name = sheet_name
        super().__init__(self._target_name)
        # Now we can use self.sheets
        self._target = self._sheets[self._target_name]
        self._header, self._data = self._make_DictList()

    def _make_DictList(self):
        data_sheet = self._bs.find("div", id=self._target["gid"])           # "Patient Data" sheet
        data_table = data_sheet.find("table") # spread sheet table
        data_tbody = data_table.find("tbody") # a body of spread sheet table
        data_rows = data_tbody.find_all("tr") # all rows
        
        # the first tr must be a header
        data_header = data_rows.pop(0)
        header = ["_acquisition_time"]
        for td in data_header.find_all("td"):
            header.append(td.text)
            
        # Prepare data as a empty list
        data = []
        if self._target_name == "Prefecture Data" or self._target_name == "Tokyo Counts":    # Prefecture Data has a "Total" row.
            data_total = data_rows.pop(0)
            content = self._get_row_contents(data_total, header)
            if content is not None:
                data.append(content)

        # the first row contains all empty cell
        _ = data_rows.pop(0)
        
        # make rows to list
        for row in data_rows:
            content = self._get_row_contents(row, header)
            if content is None:
                break
            data.append(content)
        return header, data


class COVID19_Japan():
    _c19j = None
    def __init__(self, sheet_name="Patient Data"):
        if sheet_name == "Patient Data" or \
            sheet_name == "Tokyo" or \
            sheet_name == "Osaka" or \
            sheet_name == "Prefecture Data" or \
            sheet_name == "Sum By Day" or \
            sheet_name == "Last Updated" or \
            sheet_name == "Diamond Princess Sum By Day" or \
            sheet_name == "Diamond Princess Patient Data" or \
            sheet_name == "Patient Statuses" or \
            sheet_name == "Aichi" or \
            sheet_name == "Kanagawa" or \
            sheet_name == "Chiba" or \
            sheet_name == "Tokyo Counts":
            self._c19j = COVID19_Japan_Common(sheet_name)
        elif sheet_name == "Aggregates":
            pass
            #self._c19j = COVID19_Japan_Aggregates()
        elif sheet_name == "NHK":
            pass
            #self._c19j = COVID19_Japan_NHK()
        elif sheet_name == "MHLW":
            pass
            #self._c19j = COVID19_Japan_MHLW()
        else:
            raise ValueError("SheetName is invalid")

    def get_default_CSV_filename(self):
        return self._c19j.get_default_CSV_filename()
    
    def writeCSV(self, csv_file=None):
        if csv_file is None:
            csv_file = self.get_default_CSV_filename()
        self._c19j.writeCSV(csv_file=csv_file)

    @classmethod
    def get_sheetnames(self):
        return Base_COVID19_Japan.get_sheetnames()


def main():
    parser = OptionParser()
    parser.add_option("-s", "--sheet", action="store", type="string", dest="sheetname", default="Patient Data")
    parser.add_option("-f", "--file", action="store", type="string", dest="csv_file", default=None)
    parser.add_option("-l", "--list", action="store_true", dest="list")
    
#    args = ["-s", "Prefecture Data", "-f", "test.csv"]
    (options, args) = parser.parse_args()
    
    if options.list:
        print("Sheet Names:", COVID19_Japan.get_sheetnames())
        return 0

    c19j = COVID19_Japan(options.sheetname)
    c19j.writeCSV(csv_file=options.csv_file)
    
    return 0


if __name__ == "__main__":
    main()
