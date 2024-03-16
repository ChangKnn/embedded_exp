#include <linux/fs.h>    //file stuff
#include <linux/kernel.h>   //printk
#include <linux/errno.h>    //error codes
#include <linux/module.h>   //THIS_MODULE
#include <linux/cdev.h>   //char device stuff
#include <linux/random.h>
#include <asm/uaccess.h>    //copy_to_user() 

static int major = 201;   //major number
static const char *device_name = "Position1";   //device name

static char data[3] = {0};
char random_buf[3];
int res;

//fresh coordinate
static int position_read(struct file *file_pt, char __user *user_buffer, size_t count, loff_t *possition ){
  printk(KERN_NOTICE "Position-driver: Device file is read");
  get_random_bytes(random_buf, 3);
  data[0] += random_buf[0];   //x
  data[1] += random_buf[1];   //y
  data[2] += random_buf[2];   //z
  printk(KERN_NOTICE "X: %i, Y: %i, Z: %i",random_buf[0],random_buf[1],random_buf[2]);
  if(raw_copy_to_user(user_buffer,random_buf , count) != 0)
    return -EFAULT;

  return count;
  }

static struct file_operations position_driver_fops = {
  .owner = THIS_MODULE,
  .read = position_read,
};

int register_device(void){
  int result = 0;
  printk( KERN_NOTICE "Position-driver: register_device() is called.");
  result = register_chrdev(major, device_name, &position_driver_fops);
  if(result < 0){
    printk(KERN_NOTICE "Position-driver: can\'t register character device with errorcode = %i,", result);
    return result;
  }
  printk(KERN_NOTICE "Position-driver: registered character device with major number = %i and minor number 0...255", major);
  return 0;
}

void unregister_device(void) {
  printk(KERN_NOTICE "Position-driver: unregister_device() is called");
  unregister_chrdev(major, device_name);
}
