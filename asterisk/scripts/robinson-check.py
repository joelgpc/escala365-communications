#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import mysql.connector
from asterisk.agi import AGI

def check_robinson(numero):
    """
    Consulta si un número está en la Lista Robinson local
    Retorna True si está bloqueado
    """
    try:
        db = mysql.connector.connect(
            host="mariadb",
            user="suitecrm",
            password="DB_PASSWORD",
            database="robinson"
        )
        cursor = db.cursor()
        
        # Normalizar número (quitar prefijos, espacios, etc.)
        numero_limpio = numero.replace("+34", "").replace(" ", "")
        
        query = "SELECT COUNT(*) FROM lista_robinson WHERE telefono = %s"
        cursor.execute(query, (numero_limpio,))
        result = cursor.fetchone()
        
        cursor.close()
        db.close()
        
        return result[0] > 0
        
    except Exception as e:
        # En caso de error, loguear y NO bloquear (fail-open)
        sys.stderr.write(f"Error Robinson check: {e}\n")
        return False

if __name__ == '__main__':
    agi = AGI()
    numero = sys.argv[1]
    
    bloqueado = check_robinson(numero)
    
    if bloqueado:
        agi.set_variable('ROBINSON_BLOCKED', '1')
        agi.verbose(f"Número {numero} bloqueado por Lista Robinson")
    else:
        agi.set_variable('ROBINSON_BLOCKED', '0')
        agi.verbose(f"Número {numero} verificado OK")
