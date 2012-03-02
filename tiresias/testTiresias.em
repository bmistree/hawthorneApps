system.require('tiresias.em');
system.require('module.em');
system.require('helloWorldModule.em');
system.require('birdsModule.em');


var mTire  = new Tiresias(system.self);

system.timeout(2,
               function()
               {
                   addHelloWorldModule(mTire);
                   addBirdsModule(mTire);                                      
               });
