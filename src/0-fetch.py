from pyxnat import Interface
import time
import re
import os
import sys
import tempfile
import shutil

# simple throttle to prevent problems with server responses
DELAY = 1

def get_resting_series(storage_path):

    interface = Interface(server='http://xnat.bsl.ece.vt.edu',
                          user='guest',
                          password='guest',
                          cachedir='/tmp')

    subjects = interface.select.project('ACE').subjects()

    subject_ids = []
    for s in subjects:
        experiments = s.experiments()
        for e in experiments:
            scans = e.scans()
            for sc in scans:
                time.sleep(DELAY)
                if re.search("rest", sc.attrs.get('type')):
                    time.sleep(DELAY)
                    subject_ids.append(s.attrs.get('label'))
                    time.sleep(DELAY)
                    label = e.attrs.get('label')
                    time.sleep(DELAY)
                    ident = sc.attrs.get('ID')
                    time.sleep(DELAY)
                    scan_type = sc.attrs.get('type')
                    tempdir = tempfile.mkdtemp()

                    path = os.path.join(tempdir, label, 'scans')
                    path = os.path.join(path, re.sub(' ', '_', ident+'-'+scan_type))
                    path = os.path.join(path, 'resources', 'secondary', 'files')
                    params = [s.attrs.get('ID'),e.attrs.get('ID'),ident]

                    print "Fetching Subject ID ", subject_ids[-1]
                    scans.download(tempdir, type=sc.attrs.get('ID'), extract=True)
                    shutil.copytree(path, os.path.join(storage_path, subject_ids[-1]))
                    shutil.rmtree(tempdir)

    return subject_ids

if __name__ == "__main__":

    pwd = os.getcwd()
    storage_path =  os.path.join(pwd, 'experiment')
    subject_list_filename = os.path.join(storage_path, 'subject_list.txt')
    try:
        os.mkdir(storage_path)
        storage_path = os.path.join(storage_path, 'dicom')
        os.mkdir(storage_path)
    except OSError:
        print "Storage Path", storage_path, "Exists, Halting."
        sys.exit(1)

    ids = get_resting_series(storage_path)

    with open(subject_list_filename, 'w') as subject_file:
        for i in ids:
            print>>subject_file, i
