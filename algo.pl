#!/usr/local/bin/perl
use LWP::Simple;
use funciones;
use Excel::Writer::XLSX;


#============================================================================#
#====================   CONFIGURA UNAS OPCIONES PARA EXEL  ==================#
#============================================================================#

# Create a new Excel workbook
my $workbook = Excel::Writer::XLSX->new('perl.xlsx');
# Add a worksheet
$worksheet = $workbook->add_worksheet('por seccion');
#  Add and define a format
$format = $workbook->add_format(); # Add a format
$format->set_bold();
$format->set_color('green');
$format->set_align('center');

$format_total = $workbook->add_format(); # Add a format
$format_total->set_bold();
$format_total->set_color('blue');
$format_total->set_align('rigth');
$format_total->set_bg_color('silver');
$format_total->set_border_color('black');
# Write a formatted and unformatted string, row and column notation.
$col = $row = 0;

#=======================================================================#
#====================   EXTRAE LOS DATOS POR SECCION  ==================#
#=======================================================================#
my %secciones = secciones();

my @partidos = ("UNION.POR.CORDOBA",
            "MST.NUEVA.IZQUIERDA",
            "MOVIMIENTO.AL.SOCIALISMO",
            "FRENTE.PROGRESISTA.Y.POPULAR",
            "FRENTE.DE.IZQUIERDA.Y.DE.LOS.TRABAJADORES",
            "CORDOBA.PODEMOS",
            "JUNTOS.POR.CORDOBA",
            "NULOS",
            "BLANCOS");

my %votos_secciones=votos_por_seccion(\%secciones,\@partidos);

foreach my $i (sort{$a<=>$b}(keys %votos_secciones)){
  next if $i eq 'TOTAL';
#  print "\nseccion : $i -> $secciones{$i}\n"; # impresion para consola
  $worksheet->write($row, 0, "$secciones{$i}", $format); #pone la etiqueta de la seccion en exel
  $row++;
  foreach my $j (keys %{$votos_secciones{$i}}){
#    print "     $j ->  $votos_secciones{$i}{$j}\n"; # impresion del partido y los votos para consola
    $worksheet->write($row,1, "$j"); #escribe el nombre del partido
    $worksheet->write($row,2, "$votos_secciones{$i}{$j}"); # escribe la ctidad de votos que le corresponde en la siguiente celda
    $row++;
  }
}

#escribe la seccion de total.
$row = 1;
$worksheet->write(0,4, "TOTAL",$format_total); #crea la etiquete para el total
print "\nTOTAL:\n";
foreach my $j (keys %{$votos_secciones{'TOTAL'}}){
  print "     $j ->  $votos_secciones{'TOTAL'}{$j}\n"; # impresion del partido y los votos para consola
  $worksheet->write($row,4, "$j",$format_total);
  $worksheet->write($row,5, "$votos_secciones{'TOTAL'}{$j}",$format_total);
  $row++;
}


#=======================================================================#
#====================   EXTRAE LOS DATOS POR CIRCUITO  ==================#
#=======================================================================#

my %circuitos_por_seccion = circuitos_por_secciones();
my %resultados_por_circuito = votos_por_circuito(\%circuitos_por_seccion,\@partidos);

for my $i(keys %resultados_por_circuito){
  print "$i\n";
  for my $j (keys %{$resultados_por_circuito{$i}}){
    print "    $j\n";
    for my $k (keys %{$resultados_por_circuito{$i}{$j}}){
      print "            $k   $resultados_por_circuito{$i}{$j}{$k}\n";
    }
  }
}





$workbook->close();
exit;
