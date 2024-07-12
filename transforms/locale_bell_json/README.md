# Very specific transform

This transform has a number of hard-coded items to make it work well in those situations. To make it more generic requires a lot of testing to make it work under other circumstances. 

### Hard Coded Items
* The directory where the files will be transformed
* The fact that the files are name <code>locale_bell.json</code>, not anything else. 

No other files will be transformed. 

### The transforms:
files such as 
    hard-coded-path/xx_bell.json -> hard-coded-path/bell_xx.json, 
    hard-coded-path/xx_yy_bell.json -> hard-coded-path/bell_xx_yy.json, 
