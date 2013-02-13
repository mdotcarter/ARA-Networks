import re, os, sys
import tempfile, shutil
import csv, urllib2, zipfile

def get_data(metadata, storage_path):

    password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
    server = "http://xnat.bsl.ece.vt.edu"
    password_mgr.add_password(None, server, "guest", "guest")
    handler = urllib2.HTTPBasicAuthHandler(password_mgr)
    opener = urllib2.build_opener(handler)

    uri_pattern = ("http://xnat.bsl.ece.vt.edu/REST/projects/ACE/subjects/"
                   "%(SUBJECT)s/experiments/"
                   "%(SUBJECT)s_MR/scans/"
                   "%(ID)s/files?format=zip")

    subject_ids = []
    for row in metadata:
        label = row[0].strip()
        scan_type = row[1].strip()
        ident = row[2].strip()

        print "Fetching Subject ID ", label, " scan type ", scan_type

        if label not in subject_ids: subject_ids.append(label)

        uri = uri_pattern % {"SUBJECT" : label, "ID": ident}
        print uri
        response = opener.open(uri)

        tempdir = tempfile.mkdtemp()
        print tempdir
        temp = os.path.join(tempdir, 'archive.zip')
        with open(temp, 'wb') as zfile:
            zfile.write(response.read())

        path = os.path.join(tempdir, (label+'_MR'), 'scans')
        path = os.path.join(path, re.sub(' ', '_', ident+'-'+scan_type))
        path = os.path.join(path, 'resources', 'secondary', 'files')

        # unzip file
        zipfile.ZipFile(temp, 'r').extractall(tempdir)

        if re.search("rest", scan_type):
            shutil.copytree(path, os.path.join(storage_path, "rest", label))
        if re.search("3DSPGR", scan_type):
            shutil.copytree(path, os.path.join(storage_path, "T1", label))

        shutil.rmtree(tempdir)


    return subject_ids

if __name__ == "__main__":

    pwd = os.getcwd()

    metadata = []
    subject_meta_filename = os.path.join(pwd, 'src', 'subject_metadata.txt')
    with open(subject_meta_filename, 'r') as meta_file:
        for row in csv.reader(meta_file, delimiter=','):
            metadata.append(row)

    storage_path =  os.path.join(pwd, 'experiment')
    subject_list_filename = os.path.join(storage_path, 'subject_list.txt')
    try:
        os.mkdir(storage_path)
        storage_path = os.path.join(storage_path, 'dicom')
        os.mkdir(storage_path)
        os.mkdir(os.path.join(storage_path, 'rest'))
        os.mkdir(os.path.join(storage_path, 'T1'))
    except OSError:
        print "Storage Path", storage_path, "Exists, Halting."
        sys.exit(1)

    ids = get_data(metadata, storage_path)

    with open(subject_list_filename, 'w') as subject_file:
        for i in ids:
            print>>subject_file, i
