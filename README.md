# bash-pw-basher
Need a Bash Password Basher? 

## Wait? Why? Just.... Why?
This was part of an assignment and I thought maybe it would be useful to someone. I know - there are way better ways to do this, even in bash, but hey - this was my first time doing any kind of scripting in bash. 

## What Does It Do?
It does a couple of dictionary attacks. The first one uses the 500-worst-passwords.txt file and I've included it here. You also need to specify another dictionary to use. I recommend rockyou.txt.
It also does a trivial brute-force. Right now it only works to 4 characters.

## Ok - So How Do I Use It?

Simple. Usage:

```Usage: ./pwcrack.sh [Passwords] [Dictionary File]```

The [Passwords] file should be in the format:
```username:hash```

Currently it is only able to crack SHA256 unsalted hashes.

You can also adjust a timeout for Brute Force. I don't know why this is useful - but it was in the specifications. I'll add this to an arg and default it to zero later. 

Please let me know if you find this useful at all (I'd love to know why) - and if you have any suggestions for improvement.
