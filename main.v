
import shell

const (
	auto = 'auto-workers'
	intel = 'intel-workers'
)

fn main() {
	mut sh := shell.new()
	res := sh.run('cat /etc/passwd').run('grep root').drain()
	eprintln('$res')
/*
	path := sh.getenv('PATH')
	newpath := '/sbin'
	sh.setenv('PATH', r'$path:$newpath')
*/
/*
	foo := sh.cd('~').export('FOO', 'Cow').expand('\$FOO')
	eprintln('${sh.pwd}')
	sh.cd('/tmp').pushd('/').popd()
	eprintln('${sh.pwd}')

	mut a := sh.run('ls -l /').grep('bin').drain()
	eprintln('$a')
	// sh.run(apk')),sed('s/foo/bar/g', 's/bar/cow/g')
	eprintln('foo: $foo')
	eprintln('out: $sh.stdout')
	eprintln('pwd: $sh.pwd')

	wop := sh.cat('/etc/passwd')
		.grep('root')
		.head(1)
		.sed('s/:/ /')
		// .cut(':', 0, 4)
		.sed('s/root/ROOT/').drain()
	wip:= sh.printenv().grep('PATH').drain()
	eprintln('passwd: $wop')
	eprintln('wip: $wip')
*/
}

