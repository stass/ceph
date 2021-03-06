#! /usr/bin/perl

=head1 NAME

rbd_cli_tests.pl - Script to test the RBD CLI commands and report the  
test results

=head1 SYNOPSIS

Use:
        perl rbd_cli_tests.pl [--pool pool_name][--help]

Examples:
        perl rbd_cli_tests.pl --pool test_pool 
	or
	perl rbd_cli_tests.pl  --help

=head1 DESCRIPTION

This script intends to test the RBD CLI commands for the scenarios mentioned below
and reports the test results

Positive cases 
Negative cases
-- Boundary value testing
-- Incorrect Parameter values/ Incorrect field values
-- Insufficient parameters / Extra parameters    

=head1 ARGUMENTS

rbd_cli_tests.pl takes the following arguments:
	--pool
	(optional) If not specified, rbd pool is used. 
        --help
        (optional) Displays the usage message.

=cut

use Cwd;
use RbdLib qw(perform_action create_image resize_image rename_image copy_image list_image info_image export_image import_image remove_image create_snapshots rollback_snapshots purge_snapshots list_snapshots remove_snapshot rbd_map rbd_unmap rbd_showmapped display_result _clean_up _create_rados_pool display_ceph_os_info $RADOS_MKPOOL $RADOS_RMPOOL $RBD_CREATE $RBD_RESIZE $RBD_INFO $RBD_REMOVE $RBD_RENAME $RBD_MV $RBD_LS $RBD_LIST $RBD_CLONE $RBD_EXPORT $RBD_IMPORT $RBD_CP $RBD_COPY $SNAP_CREATE $SNAP_LS $SNAP_LIST $SNAP_ROLLBACK $SNAP_PURGE $SNAP_REMOVE $POOL_RM_SUCCESS $POOL_MK_SUCCESS $RBD_EXISTS_ERR $RBD_WATCH $RBD_MAP $RBD_UNMAP $RBD_SHOWMAPPED get_command_output debug_msg );

use Pod::Usage();
use Getopt::Long();

use strict;
my ( $help, $pool );

Getopt::Long::GetOptions(
    'pool=s' => \$pool,
    'help'   => \$help
);

Pod::Usage::pod2usage( -verbose => 1 ) if ($help);

our $pool_name = "rbd";
$pool_name = $pool if ($pool);

RbdLib::banner ("Starting Test Execution");

#===========Variables used in the script========

our $img_name         = "test_img";
our $snap_name        = "snap1";
our $snap_name2       = "snap2";
our $snap_name3       = "snap3";
our $snap_name4       = "snap4";
our $new_rbd_img      = "new_rbd_img";
our $non_existing_img = "rbdimage";
our $cp_new           = "new";
our $exp_file         = "rbd_test_file1";
our $exp_file1        = "rbd_test_file2";
our $exp_file2        = "rbd_test_file3";
our $rbd_imp_file     = "test_file";
our $rbd_imp_image    = "new_imp_img";
our $content          = "This is a test file";
our $rbd_snap_new     = "new";
our $neg_img_name     = "neg_img";
our $new_img_name     = "new_img";
our $max_img_name     = "max_img";
our $img_name1        = "test_img1";
our $rbd_imp_test     = "new_test_file";
our $non_pool_name = "no_pool";
our $no_snap       = "no_snap";
our $img_name_mv   = "new_img_mv";
our $test_log      = "logfile.txt";
our $success       = "test_completed.txt";
our $fail          = "log.txt";
our $exec_cmd;
our $PASS_FLAG;
our $MSG;
our $pool_name;

print "rbd $RBD_CREATE \n";
# Tests for create image
sub create_image {
    perform_action ( $RBD_CREATE, "$img_name,pool $pool_name,size 1024", 0 );

    perform_action( $RBD_CREATE, "$img_name_mv,pool $pool_name,size 1024", 0 );
    perform_action( $RBD_CREATE, "$img_name1,pool $pool_name,size 0,order 22",
        3 );
    perform_action( $RBD_CREATE, "$img_name1,pool $pool_name,size 0",     3 );
    perform_action( $RBD_CREATE, "$neg_img_name,pool $pool_name,size -1", 3 );
    perform_action( $RBD_CREATE, "$img_name1 pool $pool_name",            3 );
    perform_action( $RBD_CREATE, "--size 1024",                           3 );
    perform_action( $RBD_CREATE,
        "$max_img_name,pool $pool_name,size 1024000000000", 0 );
    perform_action( $RBD_CREATE, "$img_name1,pool $pool_name,size 2048,order",
        2 );
    perform_action( $RBD_CREATE, "$img_name1,pool $pool_name,size,order 22",
        2 );
    perform_action( $RBD_CREATE,
        "$new_img_name,pool $pool_name,size 1024,new-format", 0 );

}

#Tests to create snapshot
sub create_snapshots {
    perform_action( $SNAP_CREATE, "--snap $snap_name $pool_name\/$img_name",
        0 );
    perform_action( $SNAP_CREATE, "--snap $snap_name $pool_name\/$img_name",
        1 );
    perform_action( $SNAP_CREATE, "$snap_name", 2 );

    perform_action($SNAP_CREATE,"--snap $snap_name2 $pool_name\/$img_name",0);
    perform_action( $SNAP_CREATE, "--snap $snap_name3 $pool_name\/$img_name",
        0 );
    perform_action( $SNAP_CREATE, "--snap $snap_name4 $pool_name\/$img_name",
        0 );
}

#Tests to rollback snapshot
sub rollback_snapshot {
    perform_action( $SNAP_ROLLBACK, "--snap $snap_name2 $pool_name\/$img_name",
        0 );
    perform_action( $SNAP_ROLLBACK,
        "--snap $rbd_snap_new $pool_name\/$img_name", 2 );
    perform_action( $SNAP_ROLLBACK,
        "--snap $snap_name $pool_name\/$new_rbd_img", 2 );
}

#Tests to purge snapshots
sub purge_snapshots {
    perform_action( $SNAP_PURGE, "$pool_name\/$img_name",    0 );
    perform_action( $SNAP_PURGE, "$pool_name\/$new_rbd_img", 2 );
}

#Tests to list snapshots for an image
sub list_snapshots {
    perform_action( $SNAP_LIST, "$pool_name\/$non_existing_img", 2 );
}

# Tests for remove snapshots
sub remove_snapshot {
    perform_action( $SNAP_REMOVE, "$pool_name\/$img_name\@$snap_name",      0 );
    perform_action( $SNAP_REMOVE, "$non_pool_name\/$img_name\@$snap_name3", 2 );
    perform_action( $SNAP_REMOVE, "$pool_name\/$img_name\@$snap_name2",     0 );
    perform_action( $SNAP_REMOVE, "$pool_name\/$non_existing_img",          2 );
    perform_action( $SNAP_REMOVE, " ",                                      2 );
}

# Tests for resize image
sub resize_image {
    perform_action( $RBD_RESIZE, "$img_name,size 1024,pool $pool_name", 0 );
    perform_action( $RBD_RESIZE, "$non_existing_img,size 1024,pool $pool_name",
        2 );
}

# Tests for list rbd image
sub list_image {
    perform_action( $RBD_LIST, "$non_pool_name", 2 );
}

# Tests to copy rbd image
sub copy_image {
    perform_action( $RBD_CP, "$pool_name\/$img_name $pool_name\/$cp_new", 0 );
    perform_action( $RBD_CP, "$pool_name\/$non_existing_img",             2 );
}

#Tests for rbd info
sub info_image {
    perform_action( $RBD_INFO, "$pool_name\/$img_name", 0 );
    perform_action( $RBD_INFO, "--snap $snap_name $pool_name\/$img_name_mv",
        2 );
    perform_action( $RBD_INFO, "--snap $no_snap $pool_name\/$img_name", 2 );
    perform_action( $RBD_INFO, "$pool_name\/$non_existing_img",         2 );
}

#Tests for rename image
sub rename_image {
    perform_action( $RBD_RENAME,
        "$pool_name\/$img_name_mv $pool_name\/$new_rbd_img", 0 );
    perform_action(  $RBD_MV,
        "$pool_name\/$new_rbd_img $pool_name\/$img_name_mv", 0 );
}

# Tests for remove image
sub remove_image {
    perform_action( $RBD_REMOVE,"$pool_name\/$img_name",0);
    perform_action( $RBD_REMOVE, "$pool_name\/$new_rbd_img", 2 );
    perform_action( $RBD_REMOVE, "--pool $pool_name $rbd_imp_image", 0 );
    perform_action( $RBD_REMOVE, "-p $pool_name $cp_new",            0 );
    perform_action( $RBD_REMOVE, " ",                                2 );
}

# Tests for export rbd image
sub export_image {
    perform_action( $RBD_EXPORT, "$pool_name\/$img_name $exp_file", 0 );
    perform_action( $RBD_EXPORT, "$pool_name\/$img_name .",         2 );
    perform_action( $RBD_EXPORT, "$pool_name\/$img_name",           2 );
    perform_action( $RBD_EXPORT,
        "--snap $snap_name $pool_name\/$img_name $exp_file1", 0 );
    perform_action( $RBD_EXPORT,
        "--snap $no_snap $pool_name\/$img_name $exp_file1", 2 );
    perform_action( $RBD_EXPORT,
        "--snap $snap_name $pool_name\/$non_existing_img $exp_file2", 2 );
}

#Tests for import file to rbd image
sub import_image {
    my $i = create_test_file( $rbd_imp_file, $content );
    if ( $i == 0 ) {
        perform_action( $RBD_IMPORT, "$rbd_imp_file $rbd_imp_image", 0 );
    }
    create_test_file( "$rbd_imp_test", 0 );
    perform_action( $RBD_IMPORT, "$rbd_imp_test $pool_name\/$rbd_imp_image",
        2 );
    perform_action( $RBD_IMPORT, "$exp_file $pool_name\/$rbd_imp_image", 2 );
}

#To map rbd image to device
sub rbd_map {

    # Execute "modprobe rbd"
    my $cmd = get_command_output("sudo modprobe rbd");
    if ( !$cmd ) {
        perform_action( $RBD_MAP, "$pool_name\/$img_name", 0 );
        rbd_showmapped();
        perform_action( $RBD_MAP, "$pool_name\/$non_existing_img", 2 );
    }
}

# To list rbd map
sub rbd_showmapped {
    perform_action( $RBD_SHOWMAPPED, "", 0 );
}

# To unmap rbd device
sub rbd_unmap {
    perform_action( $RBD_UNMAP, "/dev/rbd0", 0 );
    sleep(10);
    perform_action( $RBD_UNMAP, "/dev/rbd10", 2 );
}

# To create a test file and write to it
sub create_test_file {
    my ( $test_arg, $content ) = @_;
    my $command = "touch $test_arg";
    my $cmd     = get_command_output($command);
    if ( ( !$cmd ) && ($content) ) {
        $command = "echo $content > $test_arg";
        $cmd     = get_command_output($command);
        if ( !$cmd ) {
            my $cmd = get_command_output("ls -l $test_arg");
        }
        else {
            return 1;
        }
    }
    else {
        return 1;
    }
    return 0;
}

sub _create_rados_pool {
    $exec_cmd = get_command_output("$RADOS_RMPOOL $pool_name");
    if (   ( $exec_cmd =~ /$POOL_RM_SUCCESS/ )
        || ( $exec_cmd =~ /does not exist/ ) )
    {
        debug_msg("Pool $pool_name deleted");
    }
    $exec_cmd = get_command_output("$RADOS_MKPOOL $pool_name");
    if (   ( $exec_cmd =~ /$POOL_MK_SUCCESS/ )
        || ( $exec_cmd =~ /$RBD_EXISTS_ERR/ ) )
    {
        debug_msg("Pool $pool_name created");
    }
}

#main() starts here

display_ceph_os_info();
_create_rados_pool();
create_image();
list_image();
rename_image();
resize_image();
info_image();
create_snapshots();
export_image();
import_image();
list_snapshots();
rollback_snapshot();
remove_snapshot();
purge_snapshots();
rbd_map();
rbd_unmap();
copy_image();
remove_image();
display_result();
_clean_up();


