
import lldb
import subprocess
import random
import re
import time
import pipes
import functools

commands = dict()
class lldb_command(object):

    def __init__(self, name=None):
        self.name = name
    
    def __call__(self, f):
        name = self.name if self.name else f.__name__
        @functools.wraps(f)
        def wrapped(*args, **kwargs):
            try:
                f(*args, **kwargs)
            except KeyboardInterrupt:
                pass
        commands[name] = wrapped
        return wrapped

@lldb_command()
def layout(debugger, command, context, result, internal_dict):
    target = debugger.GetSelectedTarget()
    command = command.strip()

    def fmt(offset):
        s = "0x%x" % offset
        while len(s) < 6:
            s = ' ' + s
        return s
    cmd_offset = None
    while True:
        if command.startswith('-d '):
            command = command[2:].strip()
            def fmt(offset):
                return "%4d" % offset
        elif re.match(r'\s*-o\s*([\d]+|0x[a-fA-F\d]+)\s+(.*)', command):
            m = re.match(r'\s*-o\s*([\d]+|0x[a-fA-F\d]+)\s+(.*)', command)
            cmd_offset = m.group(1)
            command = m.group(2)
            if cmd_offset.startswith('0x'):
                cmd_offset = int(cmd_offset, 16)
            else:
                cmd_offset = int(cmd_offset)
        else:
            break
    typ = target.FindFirstType(command)
    if not typ.IsValid():
        raise Exception
    print (typ.name)
    print ("=" * len(typ.name))
    def visit(typ, indent=0, offset=0):
        for x in typ.get_members_array():
            xoffset = offset+x.GetOffsetInBytes()
            if cmd_offset is None or (xoffset <= cmd_offset and cmd_offset < xoffset + x.GetType().GetByteSize()):
                print ("%s %s%s : %s" % (fmt(xoffset), " " * indent, x.GetName(), x.GetType().GetName()))
            visit(x.GetType(), indent=indent+2, offset=xoffset)
    visit(typ)

    
    


# @lldb_command()
# def calayer(debugger, command, context, result, internal_dict):
#     """
#     dfs a CALayer layer tree
#     """
#     #print lldb.target.FindFirstType('CALayer')

#     target = debugger.GetSelectedTarget()

#     root = target.EvaluateExpression(command)
#     print command
#     print "  =>", root

#     if not root.IsValid():
#         raise Exception

#     def expr(e):
#         r = target.EvaluateExpression(e)
#         if not r.IsValid():
#             raise Exception
#         return r

#     def dfs(layer, indent=0):
#         count = expr("[[((CALayer*){addr}) sublayers] count]".format(addr = layer.addr)).GetValueAsUnsigned()
#         #print " "*indent, "count", count

#         for i in xrange(count):
#             sublayer = expr("[((CALayer*){addr}) sublayers][{i}]".format(addr = layer.addr, i=i))

#             contents = expr("[((CALayer*){addr}) contents]".format(addr = sublayer.addr))

#             print " "*indent, "sublayer", i, sublayer, "contents="+str(contents)
#             dfs(sublayer, indent+2)

#     dfs(root)

#     # print target.EvaluateExpression(
#     #     "[((CALayer*){addr}) sublayers]".format(addr = root.addr))

#     # print "a", type(root.addr), root.addr


# @lldb_command(name='ssh-remote')
# def ssh_remote(debugger, command, result, contents, internal_dict):
#     """ 
#     ssh to something and connect to debugserver.
#     syntax: ssh-remote HOST -- ARGS_FOR_DEBUGSERVER
#     syntax: ssh-remote HOST [ PID | PROCESS_NAME ]
#     """
    
#     host, command = re.split('\s+', command.strip(), 1)

#     debugserver_command = '/Developer/usr/bin/debugserver *:{port} '
    
#     if command.startswith('--'):
#         debugserver_command += command[2:].replace('{', '{{').replace('}', '}}')
#     else:
#         try:
#             pid = int(command)
#         except ValueError:
#             proc = subprocess.Popen(['ssh', host, 'pgrep', command], stdout=subprocess.PIPE)
#             out, err = proc.communicate()
#             if proc.wait() != 0 or out.strip() == '':
#                 raise Exception, "can't find process :" + command
#             pid = out.strip()
#         debugserver_command += '--attach=' + str(pid)

#     port = random.randint(2**10, 2**16)

#     cmd = map(lambda x: x.format(port=port, args=command),
#               ['ssh', '-t', '-L', '{port}:localhost:{port}', host, debugserver_command])

#     print ' '.join(map(pipes.quote, cmd))
#     ssh_proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE)

#     target = debugger.CreateTarget(None)
#     listener = lldb.SBListener("lolwtf")

#     try:
#         tries = 3
#         while tries:
#             print "sleeping.."
#             time.sleep(5)
#             tries -= 1
#             print "connecting.."
#             error = lldb.SBError()
#             target.ConnectRemote(listener, 'connect://localhost:' + str(port), 'gdb-remote', error)
#             if error.Success():
#                 print "yay"
#                 ssh_proc = None
#                 break
#             else:
#                 print error
#     finally:
#         if ssh_proc:
#             ssh_proc.kill()
#             ssh_proc.wait()
        

def __lldb_init_module(debugger, internal_dict):
    for cmd,f in commands.items():
        debugger.HandleCommand('command script add -h lol -f {mod}.{name} {cmd}'.format(
            name = f.__name__, mod=f.__module__, cmd=cmd))
