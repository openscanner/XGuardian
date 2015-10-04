//
//  XGFileSecurityHelper.m
//  XGuardian
//
//  Created by  吴亚冬 on 15/7/15.
//  Copyright (c) 2015年 杭州网蛙科技. All rights reserved.
//

#import "XGFileSecurityHelper.h"

#include <sys/types.h>
#include <sys/param.h>
#include <sys/acl.h>
#include <sys/stat.h>
#include <pwd.h>
#include <uuid/uuid.h>
#include <grp.h>
#include <membership.h>


static struct {
    acl_perm_t  perm;
    char        *name;
    int     flags;
#define ACL_PERM_DIR    (1<<0)
#define ACL_PERM_FILE   (1<<1)
} acl_perms[] = {
    {ACL_READ_DATA,     "read",     ACL_PERM_FILE},
    {ACL_LIST_DIRECTORY,    "list",     ACL_PERM_DIR},
    {ACL_WRITE_DATA,    "write",    ACL_PERM_FILE},
    {ACL_ADD_FILE,      "add_file", ACL_PERM_DIR},
    {ACL_EXECUTE,       "execute",  ACL_PERM_FILE},
    {ACL_SEARCH,        "search",   ACL_PERM_DIR},
    {ACL_DELETE,        "delete",   ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_APPEND_DATA,   "append",   ACL_PERM_FILE},
    {ACL_ADD_SUBDIRECTORY,  "add_subdirectory", ACL_PERM_DIR},
    {ACL_DELETE_CHILD,  "delete_child", ACL_PERM_DIR},
    {ACL_READ_ATTRIBUTES,   "readattr", ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_WRITE_ATTRIBUTES,  "writeattr",    ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_READ_EXTATTRIBUTES, "readextattr", ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_WRITE_EXTATTRIBUTES, "writeextattr", ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_READ_SECURITY, "readsecurity", ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_WRITE_SECURITY,    "writesecurity", ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_CHANGE_OWNER,  "chown",    ACL_PERM_FILE | ACL_PERM_DIR},
    {0, NULL, 0}
};

static struct {
    acl_flag_t  flag;
    char        *name;
    int     flags;
} acl_flags[] = {
    {ACL_ENTRY_FILE_INHERIT,    "file_inherit",     ACL_PERM_DIR},
    {ACL_ENTRY_DIRECTORY_INHERIT,   "directory_inherit",    ACL_PERM_DIR},
    {ACL_ENTRY_LIMIT_INHERIT,   "limit_inherit",    ACL_PERM_FILE | ACL_PERM_DIR},
    {ACL_ENTRY_ONLY_INHERIT,    "only_inherit",     ACL_PERM_DIR},
    {0, NULL, 0}
};


static char * uuid_to_name(uuid_t *uu) {
    int is_gid = -1;
    struct group *tgrp = NULL;
    struct passwd *tpass = NULL;
    char *name = NULL;
    uid_t id;
    
    
#define MAXNAMETAG (MAXLOGNAME + 6) /* + strlen("group:") */
    name = (char *) malloc(MAXNAMETAG);
    
    if (NULL == name) {
        //TODO: malloc error
        return NULL;
    }
    

    if (0 != mbr_uuid_to_id(*uu, &id, &is_gid))
        goto errout;

    switch (is_gid) {
        case ID_TYPE_UID:
            tpass = getpwuid(id);
            if (!tpass) {
                goto errout;
            }
            snprintf(name, MAXNAMETAG, "%s:%s", "user", tpass->pw_name);
            break;
        case ID_TYPE_GID:
            tgrp = getgrgid((gid_t) id);
            if (!tgrp) {
                goto errout;
            }
            snprintf(name, MAXNAMETAG, "%s:%s", "group", tgrp->gr_name);
            break;
        default:
            goto errout;
    }
    return name;
    
errout:
//    if (0 != mbr_uuid_to_string(*uu, name)) {
//        fprintf(stderr, "Unable to translate qualifier on ACL\n");
//        strcpy(name, "<UNKNOWN>");
//    }
    free(name);
    return NULL;
}

static void printacl(acl_t acl, int isdir)
{
    acl_entry_t entry = NULL;
    int     index;
    uuid_t      *applicable;
    char        *name = NULL;
    acl_tag_t   tag;
    acl_flagset_t   flags;
    acl_permset_t   perms;
    char        *type;
    int     i, first;
    
    
    for (index = 0; acl_get_entry(acl, entry == NULL ? ACL_FIRST_ENTRY : ACL_NEXT_ENTRY, &entry) == 0; index++) {
        if ((applicable = (uuid_t *) acl_get_qualifier(entry)) == NULL)
            continue;
        if (acl_get_tag_type(entry, &tag) != 0)
            continue;
        if (acl_get_flagset_np(entry, &flags) != 0)
            continue;
        if (acl_get_permset(entry, &perms) != 0)
            continue;
        
        name = uuid_to_name(applicable);
        acl_free(applicable);
        
        switch(tag) {
            case ACL_EXTENDED_ALLOW:
                type = "allow";
                break;
            case ACL_EXTENDED_DENY:
                type = "deny";
                break;
            default:
                type = "unknown";
        }
        

        (void)printf(" %d: %s%s %s ",
                     index,
                     name,
                     acl_get_flag_np(flags, ACL_ENTRY_INHERITED) ? " inherited" : "",type);

        
        if (name)
            free(name);
        
        for (i = 0, first = 0; acl_perms[i].name != NULL; i++) {
            if (acl_get_perm_np(perms, acl_perms[i].perm) == 0)
                continue;
            if (!(acl_perms[i].flags & (isdir ? ACL_PERM_DIR : ACL_PERM_FILE)))
                continue;
            (void)printf("%s%s", first++ ? "," : "", acl_perms[i].name);
        }
        for (i = 0; acl_flags[i].name != NULL; i++) {
            if (acl_get_flag_np(flags, acl_flags[i].flag) == 0)
                continue;
            if (!(acl_flags[i].flags & (isdir ? ACL_PERM_DIR : ACL_PERM_FILE)))
                continue;
            (void)printf("%s%s", first++ ? "," : "", acl_flags[i].name);
        }
        
        (void)putchar('\n');
    }
    
}

@implementation XGFileSecurityHelper


+ (void) getACLfromPath:(NSString*) fullPath {
    
    NSURL* url = [NSURL fileURLWithPath:fullPath];
    
    NSError* error;
    id value;
    BOOL ret = [url getResourceValue:&value forKey:NSURLFileSecurityKey error:&error];
    if (!ret) {
        NSLog(@"getResourceValue error: %@", error);
        return;
    }
    NSLog(@"getResourceValue success: %@ %@", url, value);
    
    acl_t* acl_p = NULL;
    CFFileSecurityRef fileSecurity = (__bridge CFFileSecurityRef)(value);
    Boolean res = CFFileSecurityCopyAccessControlList(fileSecurity, acl_p);
    if (!res || NULL == *acl_p) {
        NSLog(@"CFFileSecurityCopyAccessControlList failed");
        return;
    }
    
    printacl(*acl_p, 1);
    acl_free(acl_p);
    
}

@end
