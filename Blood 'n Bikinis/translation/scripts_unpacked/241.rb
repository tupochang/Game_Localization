

class DA_Error < My_Error
=begin
  
  def initialize(*args)
    super(*args)
  end
  
=end
end

class DA_Warning < My_Warning

end




class DAE_Marshal_Open < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 1
    @MESSAGE = "#99 Data Access n'a pas pu ouvrir le fichier %s pour la lecture des donnees."
    super
  end

end




class DAE_Marshal_Read < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 2
    @MESSAGE = "#99 Data Access n'a pas pu lire les donnees du fichier Marshal %s."
    super
  end

end


class DAE_Marshal_Read_Pos < DA_Error

  def initialize(file_name, pos, error=$!)
    @NUMERO = 3
    @MESSAGE = "#99 Data Access n'a pas pu lire les donnees du fichier Marshal %s a la position %d."
    super
  end

end


class DAE_File_Open < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 4
    @MESSAGE = "#99 Data Access n'a pas pu ouvrir le fichier normal %s pour la lecture des donnees."
    super
  end


end




class DAE_File_Read < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 5
    @MESSAGE = "#99 Data Access n'a pas pu lire les donnees du fichier normal %s."
    super
  end

end


class DAE_File_Not_Found < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 6
    @MESSAGE = "#99 Le fichier %s est introuvable."
    super
  end

end



class DAE_No_Dir < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 7
    @MESSAGE = "#99 Le dossier %s n'existe pas."
    super
  end

end


class DAE_File_Write < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 8
    @MESSAGE = "#99 Data Access n'a pas pu ecrire les donnees dans le fichier normal %s."
    super
  end

end



class DAE_Marshal_Write < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 9
    @MESSAGE = "#99 Data Access n'a pas pu ecrire les donnees dans le fichier Marshal %s."
    super
  end

end


class DAE_Dir_Create < DA_Error

  def initialize(file_name, error=$!)
    @NUMERO = 10
    @MESSAGE = "#99 La creation du repertoire %s a echoue car l'un des fichiers existe deja."
    super
  end

end
