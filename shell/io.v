module shell

//
pub fn (mut s Shell)write(fd int, data string) &Shell {
	if fd == 1 {
		s.stdout += data
	} else if fd == 2 {
		s.stderr += data
	}
	return s
}

