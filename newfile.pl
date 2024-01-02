#!/usr/bin/perl -w
#Nombre del Programa: newfile
#Fecha: 21 agosto 2002.
#Autor: CLM
#Descripcion: script para crear y documentar nuevos programas en perl.clm 2002


use strict;

sub creararchivo {
	my  $nombre_archivo  = $_[0];
	my  $descripcion  = $_[1];
	my  $fecha = `date +%d-%m-%y`;
	my  $autor = `whoami`;
	
open ( ARCHIVO, ">$nombre_archivo" ) || die "No puedo crear el archivo ($!)";

print ARCHIVO <<END_PRINT;
#!/usr/bin/perl -w

#Nombre del Programa:$nombre_archivo
#Fecha:$fecha#Autor:$autor#Descripcion:$descripcion 

use strict;
use diagnostics;

END_PRINT

close ( ARCHIVO);

}	


system 'clear screen';

if ( scalar @ARGV == 0 ) {
	print "================================================\n";			
	print "+Estas utilizando el script sin argumentos.    +\n\n";
	print "+Escribe el nombre del archivo a crear.        +\n\n";
	print "+EJEMPLO: newfile archivo_a_crear Descripcion. +\n";
	print "================================================\n";			
	exit;
		
} else {
	&creararchivo( @ARGV );
}	
