v-shell
=======

Chained API to write V programs similar to shellscripts.

First you need to initialize the module:

```
import shell

fn main() {
	mut sh := shell.new()
	uid := sh.cat('/etc/passwd')
		.grep('root')
		.cut(':', 2, 2)
		.head(1)
	eprintln('root uid is $uid')
}
```
