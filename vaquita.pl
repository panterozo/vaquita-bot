#!/usr/bin/env perl
use strict;
use warnings;
use Switch;
use Bot::ChatBots::Telegram::LongPoll;
use utf8;
use File::Slurp;
use Tie::File;


my $token = shift || $ENV{TOKEN};

my $lp = Bot::ChatBots::Telegram::LongPoll->new(
   token     => $token,
   processor => \&processor,
   start     => 1,
   interval => 0
);



sub processor { # tube-compliant
   print "Entra en processor\n";
   my $record = shift;
   my $text = $record->{payload}{text};
   my $username = $record->{payload}{from}{username};
   my $firstname = $record->{payload}{from}{first_name};
   if (not defined($text)){ return;}
   $text =~ s/\///g;
   $text =~ s/\@PanterozoBot//g;
   print "$text\n";

   if($text =~ m/^alea_iacta_est/){
     if($username eq 'cravg'){
	my $listo = "si";
     	open(FILE, '<', 'sorteo.txt');
     	my $count = 0;
     	$count++ while <FILE>;
     	close(FILE);
	my $ganador = (int(rand($count))+0);
     	my @log_file_contents;
     	tie @log_file_contents, 'Tie::File', "jugadores.txt"
     	  or die "Can't open filename";
     	my @log_file_conwallet;
     	tie @log_file_conwallet, 'Tie::File', "sorteo.txt"
     	  or die "Can't open filename";
        open(my $regi, '>>', 'juego.txt');
        print $regi "\n\nGANADOR:\n$log_file_contents[$ganador]\n$log_file_conwallet[$ganador]";

        my $azaaar = (int(rand(9999))+1);
        rename 'jugadores.txt', "jugadores_$azaaar.txt";
        rename 'sorteo.txt', "sorteo_$azaaar.txt";
        rename 'juego.txt', "juego_$azaaar.txt";
	my $var ="El feliz ganador de x$count es: \@$log_file_contents[$ganador]\nSu wallet es $log_file_conwallet[$ganador]\n\nSe han limpiado los registros. Los ahora antiguos registros están archivados bajo el número $azaaar. Para saber cuanto debes pagar, ocupa el comando /cuantodebopagar_$azaaar";
     	$record->{send_response} = $var;
    }else{
     $record->{send_response} = "$firstname, no estás autorizado para iniciar el sorteo...";
   } 

   }elsif($text =~ m/^cuantodebo/){
     my $archivo = 'jugadores.txt';
     open (FILE, $archivo) || die "$!\n";
     my @content = <FILE>;
     close(FILE);
     my $i;
     foreach (@content) {
                  $i++ if ($_ =~ /$username/);  #palabra que deseas buscar
     }
     my $var = "$firstname, te has comprometido a pagar x$i al ganador";
     $record->{send_response} = $var;

   }elsif($text =~ m/^cuantodebopagar (.+)/){
     my $archivo = "jugadores_$1.txt";
     open (FILE, $archivo) || die "$!\n";
     my @content = <FILE>;
     close(FILE);
     my $i;
     foreach (@content) {
                  $i++ if ($_ =~ /$username/);  #palabra que deseas buscar
     }
     my $var = "$firstname, te has comprometido a pagar x$i al ganador";
     $record->{send_response} = $var;
     

   }elsif($text =~ m/^wallets/){
     my $var = read_file('sorteo.txt');
     $record->{send_response} = $var;

   }elsif($text =~ m/^registroactual/){
     my $var = read_file('juego.txt');
     $record->{send_response} = $var;

   }elsif($text =~ m/^ayuda/){
     my $var = "VacaBot 1.0\nEste bot sirve para organizar concursos al azar.\n\nComandos:\n/ayuda\nmuestra este texto.\n\n/voy [wallet]\nIngresa al sorteo. Cada vez que se utilice aumenta la posibilidad de ganar (y el compromiso de pagar, en caso de perder).\n\n/registroactual\nMuestra listado de participantes y sus wallets que están actualmente participando.\n\n/cuantodebo\nMuestra cuanto se debe pagar en caso de perder\n\n/consultar [registro]\nVer registro de juegos anteriores y archivados.\n\n*****\nPara administradores\n/alea_iacta_est\nRealiza el sorteo\n\n/reset\nElimina registros del sorteo para comenzar desde cero.";
     $record->{send_response} = $var;

   }elsif($text =~ m/^voy (.+)/){
     my $len = bytes::length($1);
     if($len == '34'){
      my $var="$username entra al juego...";
      $record->{send_response} = $var;
      open(my $sor, '>>', 'sorteo.txt');
      print $sor "$1\n";
      open(my $jug, '>>', 'jugadores.txt');
      print $jug "$username\n";
      open(my $regi, '>>', 'juego.txt');
      print $regi "$username - $firstname\n$1\n\n";
     }else{
      my $var="$firstname, la wallet está mal escrita.";
      $record->{send_response} = $var;
     }
   }elsif($text =~ m/^consultar (.+)/){
     my $consultaregistro = "juego_$1.txt";
     my $var = read_file($consultaregistro);
     $record->{send_response} = "Registro Juego $1:\n$var";    

   }elsif($text eq 'reset'){
    if($username eq 'cravg'){

    }else{
     $record->{send_response} = "$firstname, no estás autorizado para resetear los registros...";
    } 
   }else{
#	print  "3\n";
     $record->{send_response} = "Comando invalido, $firstname";
#	print  "4\n";
   }
 #  print  "5\n";
   return $record; # follow on..
}