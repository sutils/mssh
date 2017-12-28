# mssh

the script tool to create ssh jumper server.

## Dependences

* openssh: ssh-keygen/scp/ssh
* sshpass

## Install

* download the mssh and copy to /srv
* execute below command(optional)

```.sh
cd /srv/mssh
ln -s `pwd`/mssh-conf.sh /usr/bin/mssh-conf
ln -s `pwd`/mssh-passwd.sh /usr/bin/mssh-passwd
ln -s `pwd`/mssh-useradd.sh /usr/bin/mssh-useradd
ln -s `pwd`/mssh-userdel.sh /usr/bin/mssh-userdel
```

* add mssh group and add group to sudoer(required only when deploy jumper server)

```.sh
# create group
groupadd mssh

# add ssh access group to /etc/sudoers
echo '%mssh ALL=(ALL) NOPASSWD: '`which ssh` >> /etc/sudoers
```

* add manager group and add group to sudoer(required only when you want grant user manager access to other but root)

```.sh
# create group
groupadd manager

# add user manager group to /etc/sudoers
echo '%manager ALL=(ALL) NOPASSWD: '`which useradd` >> /etc/sudoers
echo '%manager ALL=(ALL) NOPASSWD: '`which userdel` >> /etc/sudoers

```

## Usage

### Configure Jumper Server

#### 1.Prepare conf file

prepare the multi host configure file `/root/hosts.txt`

eche line will follow by `username,password,host,port`

```.txt
root,xxx,loc.m,22
root,xxx,192.168.2.xx
```

#### 2.Create all rsa key by mssh

execute below command on root user

```.sh
mssh-conf /root/hosts.txt
```

eg: the `/root/hosts.txt` can be deleted after this step.

#### 3.Test auto login is correct(optional)

run ssh command on root to test the auto login

```.sh
ssh root@loc.m
```

### Add manager user

```.sh
mssh-useradd manager mgr1 123
```

### Use jumper server

#### 1.Add user

add other user to access the auto login by root or manager user(add user to manager group)

```.sh
mssh-useradd mssh test1 123
```

#### 2.Use jumper server

* login to jumper server by `ssh test1@xxx` (password required)
* login to target server by `ssh root@loc.m` (not password)

### Configure local user auto login to multi server

follow `Configure Jumper Server` step 1 and step 2 and run the command on login user (not root if it is not using)

### Change all host password

using the same configure file of jumper server

```.sh
mssh-passwd /root/hosts.txt xxx
```