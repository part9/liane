package Liane::List;

use strict;
use warnings;
use utf8;

use Wx qw( :everything );

# Returns index of (first) selected item
# in given ListCtrl-List.
sub get_selected_index {
    my $self     = shift;
    my $listctrl = shift;
    
    my $item_count = $listctrl->GetItemCount;
    
    # Iterate over all items to see
    # which one is selected.
    for ( my $i = 0; $i < $item_count; $i++ )  {
        
        if ( $listctrl->GetItemState( 
                    $i, wxLIST_STATE_SELECTED )  == wxLIST_STATE_SELECTED ) {
            return $i;
        }        
    }
}

sub deselect_all_but_this_item {
    my $self      = shift;
    my $listctrl  = shift;
    my $this_item = shift;
    
    # This beautifully handcrafted code implements
    # single-selection behavior for the list control.
    # wxLC_SINGLE_SEL does not seem to work in combination
    # with wxLC_REPORT and SetSingleStyle doesn't affect
    # the behavior, either.
    
    my $item_count = $listctrl->GetItemCount;
    
    # Deselect all items in the list, except this_item.
    for ( my $i = 0; $i < $item_count; $i++ )  {
        $listctrl->SetItemState( $i, 0, wxLIST_STATE_SELECTED )
            unless $i == $this_item;
    }
}

1;
