
import lldb
import subprocess
import random
import re
import time
import pipes

commands = dict()
class lldb_command(object):

    def __init__(self, name=None):
        self.name = name
    
    def __call__(self, f):
        commands[self.name if self.name else f.__name__] = f
        return f

@lldb_command(name='ssh-remote')
def ssh_remote(debugger, command, result, internal_dict):
    """ 
    ssh to something and connect to debugserver.
    syntax: ssh-remote HOST -- ARGS_FOR_DEBUGSERVER
    syntax: ssh-remote HOST [ PID | PROCESS_NAME ]
    """
    
    host, command = re.split('\s+', command.strip(), 1)

    debugserver_command = '/Developer/usr/bin/debugserver *:{port} '
    
    if command.startswith('--'):
        debugserver_command += command[2:].replace('{', '{{').replace('}', '}}')
    else:
        try:
            pid = int(command)
        except ValueError:
            proc = subprocess.Popen(['ssh', host, 'pgrep', command], stdout=subprocess.PIPE)
            out, err = proc.communicate()
            if proc.wait() != 0 or out.strip() == '':
                raise Exception, "can't find process :" + command
            pid = out.strip()
        debugserver_command += '--attach=' + str(pid)

    port = random.randint(2**10, 2**16)

    cmd = map(lambda x: x.format(port=port, args=command),
              ['ssh', '-t', '-L', '{port}:localhost:{port}', host, debugserver_command])

    print ' '.join(map(pipes.quote, cmd))
    ssh_proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE)

    target = debugger.CreateTarget(None)
    listener = lldb.SBListener("lolwtf")

    try:
        tries = 3
        while tries:
            time.sleep(1)
            tries -= 1
            print "connecting.."
            error = lldb.SBError()
            target.ConnectRemote(listener, 'connect://localhost:' + str(port), 'gdb-remote', error)
            if error.Success():
                print "yay"
                ssh_proc = None
                break
            else:
                print error
    finally:
        if ssh_proc:
            ssh_proc.kill()
            ssh_proc.wait()
        

def __lldb_init_module(debugger, internal_dict):
    for cmd,f in commands.items():
        debugger.HandleCommand('command script add -h lol -f {mod}.{name} {cmd}'.format(
            name = f.__name__, mod=f.__module__, cmd=cmd))
