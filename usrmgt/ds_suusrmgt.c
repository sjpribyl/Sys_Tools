/******************************************************************************
*
*  Script Name : ds_suusrmgt
*
*  Description :  Wrap root for usrmgr and grpmgr for users secadm and secopr 
*					and group security
*
*  Unit    : AIS UNIX
*
*******************************************************************************
*
*  Date    	Programmer      Description
*  -------- ------------ 	-------------------------------
*  3/3/09 	Steve Pribyl  	Creation
*  4/27/09	Steve Pribyl	2.0.0
*							Improve error reporting
*
******************************************************************************/

#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include <sys/types.h>
#include <syslog.h>
#include <pwd.h>
#include <grp.h>
#include <errno.h>
#include <string.h>

#define USRMGR "/allstate/scripts/usrmgr"
#define GRPMGR "/allstate/scripts/grpmgr"

#define FAILED 0
#define SECOPR 1
#define SECADM 2
#define SECURITY 3

int main(int argc, char** argv) 
{
	uid_t uid=getuid();
	int	user_good=FAILED;
	char 	err_mesg[1024]={0};
	int	myerror=0,i=0;		

	for (i=0;i<argc;i++) {
		if(!strcmp("-v",argv[i])) {
			printf ("ds_suusrmgt: Version 2.0.0 - %s %s\n", __DATE__,__TIME__);
			return 0;
		}
	}

	struct passwd *pwd=getpwuid(uid);
	if(pwd==NULL) {
		myerror=errno;
		sprintf(err_mesg,"ds_suusrmgt: ERROR: Unable to find user with uid \"%d\"! -  %d:%s\n",myerror,strerror(myerror));
	} else {
		if (strlen(pwd->pw_name)==6 && !strcmp("secadm",pwd->pw_name)) {
			//is the user secadm
			user_good=SECADM;
		} else if (strlen(pwd->pw_name)==6 && !strcmp("secopr",pwd->pw_name)) {
			user_good=SECOPR;
		} else {
			//is the user a member of security group (primary or secondary)
			struct group *grp=getgrnam("security");
			if (grp==NULL) {
				myerror=errno;
				sprintf(err_mesg,"ds_suusrmgt: ERROR: Unable to find group \"security\"! -  %d:%s\n",errno,strerror(myerror));
			} else {
				if(grp->gr_gid == pwd->pw_gid) { //Is the primary group the security group
					user_good=SECURITY;
				} else {
					int gsize = getgroups(0,NULL);
					gid_t *glist=NULL;
					if(gsize>0) {
						glist=calloc(gsize,sizeof(gid_t));
						getgroups(gsize,glist);
						for(i=0; i<gsize;i++) {
							if(grp->gr_gid == glist[i]) {
								user_good=SECURITY;
							}
						}
						free(glist);
					}
				}
			}
		}
	}

	if(user_good) {
		int prog_good=0;
		if(user_good==SECOPR && (argc==7 || argc==8) && !strcmp(argv[1],USRMGR) && !strcmp(argv[2],"-O") && !strcmp(argv[4],"-p")) {
			prog_good=1;
		} else if((user_good==SECADM || user_good==SECURITY) && argc>4 && (!strcmp(argv[1],USRMGR) || !strcmp(argv[1],GRPMGR)) && !strcmp(argv[2],"-O")) {
			prog_good=1;
		}
		if (prog_good) {
			char **newargv=calloc(argc,sizeof(char*));  //argv-1 and a null at the end
			for (i=1;i<argc;i++) {
				newargv[i-1]=argv[i];
			}
			i=0;
			//Execute the command with arguments and a NULL enviroment
			setuid(0);
			setgid(0);
			execve(newargv[0], newargv, NULL);
		} else {
			printf("ds_suusrmgt: Permission Denied! - Invalid Program or Arguments\n");
			//TODO void syslog(int priority, const char *message,  .../*  arguments */);
		}
	} else {
		if(err_mesg[0]) {
			printf(err_mesg);
		} else  {
			printf("ds_suusrmgt: Permission Denied! - Invalid User\n");
			//TODO void syslog(int priority, const char *message,  .../*  arguments */);
		}
	}
	exit(1);
}
