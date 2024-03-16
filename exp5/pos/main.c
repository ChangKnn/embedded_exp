#include "position_driver.h"
#include <linux/init.h>   //module_init, module_exit
#include <linux/module.h>   //version info, MODULE_LICENSE, MODULE_AUTHOR, printk()

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Kun Zhang");

static int position_driver_init(void){
  int result = 0;
  printk(KERN_NOTICE "Position-driver: Initialization started");
  result = register_device();
  return result;
}

static void position_driver_exit(void){
  printk(KERN_NOTICE "Position-driver: Exiting");
  unregister_device();
}

module_init(position_driver_init);
module_exit(position_driver_exit);
