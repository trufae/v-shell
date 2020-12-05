module shell

import os
import regex

pub struct Shell {
pub mut:
	oldpwd string
	pwd string
	stdout string
	stderr string
	dirs []string
}

pub fn new() Shell {
	mut s := Shell{}
	return s
}

pub fn (s Shell)expand(a string) string {
	mut r := a.replace('~', '\${HOME}')
	for k, v in os.environ() {
		r = r.replace('\$$k', v)
		r = r.replace('\${$k}', v)
	}
	return r
}

pub fn (mut s Shell)printenv() &Shell {
	for k, v in os.environ() {
		s.stdout += '$k=$v\n'
	}
	return s
}

pub fn (mut s Shell)export(a string, b string) &Shell {
	os.setenv(a, s.expand(b), true)
	return s
}

pub fn (mut s Shell)popd() &Shell {
	oldir := s.dirs.pop()
	s.cd(oldir)
	return s
}

pub fn (mut s Shell)pushd(a string) &Shell {
	s.dirs << os.getwd()
	s.cd(a)
	return s
}

pub fn (mut s Shell)cd(a string) &Shell {
	s.oldpwd = os.getwd()
	b := s.expand(a)
	os.chdir(b)
	s.pwd = b
	return s
}

pub fn (mut s Shell)mkdir(a string) &Shell {
	os.mkdir(a)
	return s
}

pub fn (mut s Shell)tail(a int) &Shell {
	mut lines := s.stdout.split('\n')
	lines.reverse_in_place()
	mut res := []string{}
	mut count := 0
	for line in lines {
		if count >= a {
			break
		}
		res << line
		count++
	}
	res.reverse_in_place()
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)cut(delim string, from int, to int) &Shell {
	lines := s.stdout.split('\n')
	mut res := []string{}
	for line in lines {
		words := line.split(delim)
		mut lineres := []string{}
		for i := 0; i < words.len; i++ {
			if i >= from && (to == -1 || i <= to) {
				lineres << words[i]
			}
		}
		if lineres.len > 0 {
			res << lineres.join(' ')
		}
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)head(a int) &Shell {
	lines := s.stdout.split('\n')
	mut res := []string{}
	mut count := 0
	for line in lines {
		if count >= a {
			break
		}
		res << line
		count++
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)trim(a string) &Shell {
	lines := s.stdout.split('\n')
	mut res := []string{}
	for line in lines {
		res << line.trim_space()
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)tab() &Shell {
	lines := s.stdout.split('\n')
	mut res := []string{}
	for line in lines {
		mut words := line.split(' ') // XXX doesnt work with multiple spaces
		res << words.join('\t')
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)grep(a string) &Shell {
	lines := s.stdout.split('\n')
	mut res := []string{}
	for line in lines {
		if line.contains(a) {
			res << line
		}
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)grep_v(a string) &Shell {
	lines := s.stdout.split('\n')
	mut res := []string{}
	for line in lines {
		if !line.contains(a) {
			res << line
		}
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (mut s Shell)sort(a string) &Shell {
	mut lines := s.stdout.split('\n')
	lines.sort()
	s.stdout = lines.join('\n')
	return s
}

pub fn (mut s Shell)uniq() &Shell {
	mut res := []string{}
	mut lines := s.stdout.split('\n')
	lines.sort()
	mut oline := ''
	for line in lines {
		if line == oline {
			continue
		}
		res << line
		oline = line
	}
	s.stdout = res.join('\n')
	return s
}

pub fn (s Shell)str() string {
	return s.stdout
}

pub fn (mut s Shell)drain() string {
	out := s.stdout
	s.stdout = ''
	// XXX defer doesnt works well
	// defer { s.stdout = '' }
	return out
}

pub fn (mut s Shell)sed(t string) &Shell {
	if t.len > 0 && t[0] == `s` {
		mut res := []string{}
		delim := '/' // ${t[1]}'
		tt := t.replace('\\/', '\\_')
		args := tt.split('$delim')
		if args.len != 4 {
			panic('invalid regex')
		}
		global := args[3] == 'g'
		k := args[1].replace('\\_', '\\/')
		v := args[2].replace('\\_', '\\/')
		eprintln('k:$k')
		eprintln('v:$v')
		mut lines := s.stdout.split('\n')
		mut re := regex.new()
		re.compile_opt('$k')
		for line in lines {
			lineres := re.replace(line, '$v')
			res << lineres
		}
		s.stdout = res.join('\n')
	}
	return s
}

pub fn (mut s Shell)tac(t string) &Shell {
	mut lines := os.read_lines(t) or {
		eprintln('os.read_lines: $err')
		return s
	}
	lines.reverse_in_place()
	s.stdout += lines.join('\n')
	return s
}

pub fn (mut s Shell)cat(t string) &Shell {
	data := os.read_file(t) or {
		eprintln('os.read_file: $err')
		return s
	}
	s.stdout += data
	return s
}

pub fn (mut s Shell)run(cmd string) &Shell {
	// XXX dont use a temporary file
	os.write_file('/tmp/.in', s.stdout)
	t := '/tmp/.out'
	os.system('$cmd > $t < /tmp/.in')
	data := os.read_file(t) or {
		os.rm(t)
		panic('oops')
	}
	s.stdout = '$data'
	os.rm(t)
	return s
}

/*
pub fn (mut s Shell)getenv(v string) &Shell {
	s.output += os.environ()[v]
	return s
}
*/
