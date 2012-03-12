#!/usr/bin/python

import sys;


def generateConfig(configFilename,prefix):

    filer = open(configFilename,'w');

    filer.write('''
{
    "app" :
    {
        "name" : "tiresias",
        "directory" : "tiresias",
        "files" :
        {''');
    appendFileWrite(filer,'avatar.db',prefix,True);
    appendFileWrite(filer,'birdsModule.em',prefix,True);
    appendFileWrite(filer,'controlsModule.em',prefix,True);
    appendFileWrite(filer,'helloWorldModule.em',prefix,True);
    appendFileWrite(filer,'module.em',prefix,True);
    appendFileWrite(filer,'testTiresias.em',prefix,True);
    appendFileWrite(filer,'tiresiasAvatar.em',prefix,True);
    appendFileWrite(filer,'tiresias.em',prefix,True);
    appendFileWrite(filer,'tiresiasUtil.em',prefix,True);
    appendFileWrite(filer,'birdsScripts/boids2o.em',prefix,True);
    appendFileWrite(filer,'birdsScripts/deltaTimer.em',prefix,False);

    # filer.write('''        }
#     },
#     "binary" :
#     {
#         "name" : "cppoh",
#         "args" :
#         {
#             "object-factory-opts" : "--db=avatar.db"
#         }
#     }
# }''');
    
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
