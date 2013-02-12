import virtualenv, textwrap
output = virtualenv.create_bootstrap_script(textwrap.dedent("""
from os.path import join
from os import getcwd
from subprocess import call
def after_install(options, home_dir):
    pip = join(getcwd(), home_dir, 'bin', 'pip')
    easy = join(getcwd(), home_dir, 'bin', 'easy_install')
    call([pip, 'install', 'numpy'])
    call([pip, 'install', 'nibabel'])
    call([easy, 'lxml'])
    call([easy, 'httplib2'])
    call([pip, 'install', 'pyxnat'])
"""))
f = open('devenv-bootstrap.py', 'w').write(output)
