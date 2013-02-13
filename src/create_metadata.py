from pyxnat import Interface
import time, re

# simple throttle to prevent problems with server responses
DELAY = 1

def get_metadata(server):

    interface = Interface(server,
                          user='guest',
                          password='guest',
                          cachedir='/tmp')

    subjects = interface.select.project('ACE').subjects()

    params = []
    for s in subjects:
        experiments = s.experiments()
        for e in experiments:
            scans = e.scans()
            for sc in scans:
                time.sleep(DELAY)
                scan_type = sc.attrs.get('type')
                if re.search("rest", scan_type) or re.search("3DSPGR", scan_type):
                    time.sleep(DELAY)
                    label = s.attrs.get('label')
                    time.sleep(DELAY)
                    ident = sc.attrs.get('ID')
                    time.sleep(DELAY)
                    print label
                    params.append((label, scan_type, ident))


    return params

if __name__ == "__main__":

    server='http://xnat.bsl.ece.vt.edu'

    params = get_metadata(server)

    subject_meta_filename = 'subject_metadata.txt'

    with open(subject_meta_filename, 'w') as subject_file:
        for item in params:
            print item[0], ',', item[1], ',', item[2]
            print>>subject_file, item[0], ',', item[1], ',', item[2]
