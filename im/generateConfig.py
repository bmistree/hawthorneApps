#!/usr/bin/python

import sys;


def generateConfig(configFilename,prefix):

    filer = open(configFilename,'w');

    filer.write('''
{
    "app" :
    {
        "name" : "melvilleChat",
        "directory" : "melvilleWorld",
        "files" :
        {''');
    appendFileWrite(filer,'avatar.db',prefix,True);
    appendFileWrite(filer,'appGui.em',prefix,True);
    appendFileWrite(filer,'convGUI.em',prefix,True);
    appendFileWrite(filer,'friend.em',prefix,True);
    appendFileWrite(filer,'group.em',prefix,True);
    appendFileWrite(filer,'imUtil.em',prefix,True);
    appendFileWrite(filer,'melvilleAvatar.em',prefix,True);
    appendFileWrite(filer,'room.em',prefix,True);
    appendFileWrite(filer,'roomGui.em',prefix,True);
    appendFileWrite(filer,'test.em',prefix,False);

    filer.write('''        }
    },
    "binary" :
    {
        "name" : "cppoh",
        "args" :
        {
            "object-factory-opts" : "--db=avatar.db",
            "servermap": "local",
            "servermap-options": "--host=sns30.cs.princeton.edu --port=6880"
        }
    }
}''');

    
    filer.flush();
    filer.close();


def appendFileWrite(fileStream,filename,prefix,withComma):
    fileStream.write('    "' + filename + '" : "' + prefix + filename + '"');
    if (withComma):
        fileStream.write(',');

    fileStream.write('\n');        
    fileStream.flush();


    

if __name__ == "__main__":

    if (len(sys.argv) != 3):
        print('\n\n');
        print('Usage error: <name of file to save to> <prefix for files, eg. http, file:///home...>')
        print('\n\n');
    else:
        generateConfig(sys.argv[1],sys.argv[2]);
