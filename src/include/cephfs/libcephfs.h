// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab
/*
 * Ceph - scalable distributed file system
 *
 * Copyright (C) 2009-2011 New Dream Network
 *
 * This is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License version 2.1, as published by the Free Software
 * Foundation.  See file COPYING.
 *
 */

#ifndef CEPH_LIB_H
#define CEPH_LIB_H

#include <utime.h>
#include <sys/stat.h>
#include <sys/types.h>

// FreeBSD compatibility
#ifdef __FreeBSD__
typedef off_t loff_t;
typedef off_t off64_t;
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
 * On FreeBSD the offset is 64 bit, but libc doesn't announce it in the way glibc does.
 */
#if !defined(__FreeBSD__) && !defined(__USE_FILE_OFFSET64)
# error libceph: must define __USE_FILE_OFFSET64 or readdir results will be corrupted
#endif

struct ceph_mount_info;
struct ceph_dir_result;
struct CephContext;

const char *ceph_version(int *major, int *minor, int *patch);

/* initialization */
int ceph_create(struct ceph_mount_info **cmount, const char * const id);

/* initialization with an existing configuration */
int ceph_create_with_context(struct ceph_mount_info **cmount, struct CephContext *conf);

/* Activate the mount */
int ceph_mount(struct ceph_mount_info *cmount, const char *root);

/* Destroy the ceph mount instance */
void ceph_shutdown(struct ceph_mount_info *cmount);

/* Config
 *
 * Functions for manipulating the Ceph configuration at runtime.
 */
int ceph_conf_read_file(struct ceph_mount_info *cmount, const char *path_list);

int ceph_conf_parse_argv(struct ceph_mount_info *cmount, int argc, const char **argv);

/* Sets a configuration value from a string.
 * Returns 0 on success, error code otherwise. */
int ceph_conf_set(struct ceph_mount_info *cmount, const char *option, const char *value);

/* Returns a configuration value as a string.
 * If len is positive, that is the maximum number of bytes we'll write into the
 * buffer. If len == -1, we'll call malloc() and set *buf.
 * Returns 0 on success, error code otherwise. Returns ENAMETOOLONG if the
 * buffer is too short. */
int ceph_conf_get(struct ceph_mount_info *cmount, const char *option, char *buf, size_t len);

int ceph_statfs(struct ceph_mount_info *cmount, const char *path, struct statvfs *stbuf);

/* Get the current working directory.
 *
 * The pointer you get back from this function will continue to be valid until
 * the *next* call you make to ceph_getcwd, at which point it will be invalidated.
 */
const char* ceph_getcwd(struct ceph_mount_info *cmount);

int ceph_chdir(struct ceph_mount_info *cmount, const char *s);

int ceph_opendir(struct ceph_mount_info *cmount, const char *name, struct ceph_dir_result **dirpp);
int ceph_closedir(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp);
struct dirent * ceph_readdir(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp);
int ceph_readdir_r(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp, struct dirent *de);
int ceph_readdirplus_r(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp, struct dirent *de,
		       struct stat *st, int *stmask);
int ceph_getdents(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp, char *name, int buflen);
int ceph_getdnames(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp, char *name, int buflen);
void ceph_rewinddir(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp);
loff_t ceph_telldir(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp);
void ceph_seekdir(struct ceph_mount_info *cmount, struct ceph_dir_result *dirp, loff_t offset);

int ceph_link(struct ceph_mount_info *cmount, const char *existing, const char *newname);
int ceph_unlink(struct ceph_mount_info *cmount, const char *path);
int ceph_rename(struct ceph_mount_info *cmount, const char *from, const char *to);

/* dirs */
int ceph_mkdir(struct ceph_mount_info *cmount, const char *path, mode_t mode);
int ceph_mkdirs(struct ceph_mount_info *cmount, const char *path, mode_t mode);
int ceph_rmdir(struct ceph_mount_info *cmount, const char *path);

/* symlinks */
int ceph_readlink(struct ceph_mount_info *cmount, const char *path, char *buf, loff_t size);
int ceph_symlink(struct ceph_mount_info *cmount, const char *existing, const char *newname);

/* inode stuff */
int ceph_lstat(struct ceph_mount_info *cmount, const char *path, struct stat *stbuf);

int ceph_setattr(struct ceph_mount_info *cmount, const char *relpath, struct stat *attr, int mask);
int ceph_chmod(struct ceph_mount_info *cmount, const char *path, mode_t mode);
int ceph_chown(struct ceph_mount_info *cmount, const char *path, uid_t uid, gid_t gid);
int ceph_utime(struct ceph_mount_info *cmount, const char *path, struct utimbuf *buf);
int ceph_truncate(struct ceph_mount_info *cmount, const char *path, loff_t size);

/* file ops */
int ceph_mknod(struct ceph_mount_info *cmount, const char *path, mode_t mode, dev_t rdev);
int ceph_open(struct ceph_mount_info *cmount, const char *path, int flags, mode_t mode);
int ceph_close(struct ceph_mount_info *cmount, int fd);
loff_t ceph_lseek(struct ceph_mount_info *cmount, int fd, loff_t offset, int whence);
int ceph_read(struct ceph_mount_info *cmount, int fd, char *buf, loff_t size, loff_t offset);
int ceph_write(struct ceph_mount_info *cmount, int fd, const char *buf, loff_t size,
	       loff_t offset);
int ceph_ftruncate(struct ceph_mount_info *cmount, int fd, loff_t size);
int ceph_fsync(struct ceph_mount_info *cmount, int fd, int syncdataonly);
int ceph_fstat(struct ceph_mount_info *cmount, int fd, struct stat *stbuf);

int ceph_sync_fs(struct ceph_mount_info *cmount);

/* xattr support */
int ceph_getxattr(struct ceph_mount_info *cmount, const char *path, const char *name, 
	void *value, size_t size);
int ceph_lgetxattr(struct ceph_mount_info *cmount, const char *path, const char *name, 
	void *value, size_t size);
int ceph_listxattr(struct ceph_mount_info *cmount, const char *path, char *list, size_t size);
int ceph_llistxattr(struct ceph_mount_info *cmount, const char *path, char *list, size_t size);
int ceph_removexattr(struct ceph_mount_info *cmount, const char *path, const char *name);
int ceph_lremovexattr(struct ceph_mount_info *cmount, const char *path, const char *name);
int ceph_setxattr(struct ceph_mount_info *cmount, const char *path, const char *name, 
	const void *value, size_t size, int flags);
int ceph_lsetxattr(struct ceph_mount_info *cmount, const char *path, const char *name, 
	const void *value, size_t size, int flags);



/* expose file layout */
int ceph_get_file_stripe_unit(struct ceph_mount_info *cmount, int fh);
int ceph_get_file_pool(struct ceph_mount_info *cmount, int fh);
int ceph_get_file_replication(struct ceph_mount_info *cmount, int fh);
int ceph_get_file_stripe_address(struct ceph_mount_info *cmount, int fd,
				 loff_t offset, char *buf, int buflen);

/* set default layout for new files */
int ceph_set_default_file_stripe_unit(struct ceph_mount_info *cmount, int stripe);
int ceph_set_default_file_stripe_count(struct ceph_mount_info *cmount, int count);
int ceph_set_default_object_size(struct ceph_mount_info *cmount, int size);
int ceph_set_default_preferred_pg(struct ceph_mount_info *cmount, int osd);
int ceph_set_default_file_replication(struct ceph_mount_info *cmount, int replication);

/* read from local replicas when possible */
int ceph_localize_reads(struct ceph_mount_info *cmount, int val);

/* return osd on local node, if any */
int ceph_get_local_osd(struct ceph_mount_info *cmount);

/* Get the CephContext of this mount */
struct CephContext *ceph_get_mount_context(struct ceph_mount_info *cmount);

#ifdef __cplusplus
}
#endif

#endif
