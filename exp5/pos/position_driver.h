#ifndef POSITION_DRIVER_H_
#define POSITION_DRIVER_H_
#include <linux/compiler.h>

__must_check int register_device(void);
void unregister_device(void);

#endif
