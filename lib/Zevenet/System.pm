#!/usr/bin/perl
###############################################################################
#
#    Zevenet Software License
#    This file is part of the Zevenet Load Balancer software package.
#
#    Copyright (C) 2014-today ZEVENET SL, Sevilla (Spain)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

use strict;

=begin nd
Function: zsystem

	Run a command with tuned system parameters.

Parameters:
	exec - Command to run.

Returns:
	integer - ERRNO or return code.

See Also:
	<runFarmGuardianStart>, <_runHTTPFarmStart>, <runHTTPFarmCreate>, <_runGSLBFarmStart>, <_runGSLBFarmStop>, <runGSLBFarmReload>, <runGSLBFarmCreate>, <setGSLBFarmStatus>
=cut
sub zsystem
{
	my ( @exec ) = @_;

	my $out   = `. /etc/profile && @exec`;
	my $error = $?;

	if ( $error or &debug() )
	{
		my $message = $error ? 'failed' : 'running';
		&zenlog( "$message: @exec" );
		&zenlog( "output: $out" ) if $out;
	}

	return $error;
}

=begin nd
Function: getTotalConnections

	Get the number of current connections on this appliance.

Parameters:
	none - .

Returns:
	integer - The number of connections.

See Also:
	zapi/v3/system_stats.cgi
=cut
sub getTotalConnections
{
	my $conntrack = &getGlobalConfiguration ( "conntrack" );
	my $conns = `$conntrack -C`;
	$conns =~ s/(\d+)/$1/;
	$conns += 0;
	
	return $conns;
}

=begin nd
Function: indexOfElementInArray

	Get the index of the first position where an element if found in an array.

Parameters:
	searched_element - Element to search.
	array_ref        - Reference to the array to be searched.

Returns:
	integer - Zero or higher if the element was found. -1 if the element was not found. -2 if no array reference was received.

See Also:
	Zapi v3: <new_bond>
=cut
sub indexOfElementInArray
{
	my $searched_element = shift;
	my $array_ref = shift;

	if ( ref $array_ref ne 'ARRAY' )
	{
		return -2;
	}
	
	my @arrayOfElements = @{ $array_ref };
	my $index = 0;
	
	for my $list_element ( @arrayOfElements )
	{
		if ( $list_element eq $searched_element )
		{
			last;
		}

		$index++;
	}

	# if $index is greater than the last element index
	if ( $index > $#arrayOfElements )
	{
		# return an invalid index
		$index = -1;
	}

	return $index;
}

1;
