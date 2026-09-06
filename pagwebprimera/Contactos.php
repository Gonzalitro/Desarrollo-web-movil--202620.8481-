<!DOCTYPE html>
<html lang="es">
    <head>
        <title>Paguina Principal </title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <style>
            .logo {
                height: 45px;
                width: 45px;
                border-radius: 50%;
                object-fit: cover;
           }
        </style>
    </head>
    <body style="background-color: #0b1f3a;">
        <!-- navbar --> 
         <nav class="navbar navbar-expand-sm bg-dark navbar-dark">
            <div class="container-fluid">
    <a class="navbar-brand" href="index.php">
        <img src="img/ddd.png" class="logo">
    </a>   
        <nav class="navbar navbar-expand-sm bg-dark navbar-dark">
            <div class="container-fluid">
            <a class="navbar-brand" href="index.php"></a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#collapsibleNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="collapsibleNavbar">
            <ul class="navbar-nav">
            <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">Opciones</a>
            <ul class="dropdown-menu">
            <li><a class="dropdown-item" href="Contactos.php">Go to 1</a></li>
            <li><a class="dropdown-item" href="Empresa.php">Go to 2</a></li>
            <li><a class="dropdown-item" href="Servicios.php">Go to 3</a></li>
            <li><a class="dropdown-item" href="indexfake.php">And go to Fake index again</a></li>
          </ul>
        </li>
       <li class="nav-item">
          <a class="nav-link" href="Productos.php">ONE</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="Servicios.php">CAROUSEL</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="Contactos.php">THREE</a>
        </li>  
      </ul> 
      </ul>
        </div>
        <button type="button" class="btn btn-outline-primary "data-bs-toggle="modal" data-bs-target="#myModal">Acceder</button>
            </div>
        </nav>
    
        <!-- container -->
        <div class="container-fluid bg-warning">
            <form action="Empresa.php">
            <div class="mb-2 mt-2">
            <label for="email" class="form-label">Email:</label>
            <input type="email" class="form-control" id="email" placeholder="Enter email" name="email">
            </div>
            <label for="comment">Comments:</label>
            <textarea class="form-control" rows="5" id="comment" name="text"></textarea>
            <buttone type="submit" class="btn btn-primary mt-1">Enviar</button>
            </form>
        </div>

        <!-- footer -->
        <div class="container-fluid bg-dark">
            <div class="row">
                <div class="col-4"></div>
                <div class="col-4 d-flex justify-content-center"
                style="color:white"><strong>Miempresa@hotmail.com</strong></div>
                <div class="col-4"></div>
            </div>
        </div>
         <!-- modal -->
          <div class="modal fade" id="myModal">
  <div class="modal-dialog">
    <div class="modal-content">

      <!-- Modal Header -->
      <div class="modal-header">
            <h4 class="modal-title">Autenticar</h4>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <!-- Modal body -->
      <div class="modal-body">
        <form action="Empresa.php">
        <div class="mb-2 mt-2">
            <label for="email" class="form-label">Email:</label>
            <input type="email" class="form-control" id="email" placeholder="Enter email" name="email">
        </div>
        <div class="mb-2">
            <label for="pwd" class="form-label">Password:</label>
            <input type="password" class="form-control" id="pwd" placeholder="Enter password" name="pswd">
        </div>
        <div class="form-check mb-2">
            <label class="form-check-label">
            <input class="form-check-input" type="checkbox" name="remember"> Remember me
            </label>
        </div>
        <button type="submit" class="btn btn-primary">Login <i class="fa fa-check-circle"></i></button></button>
        </form>
      </div>

      <!-- Modal footer -->
      <div class="modal-footer">
            <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Close</button>
      </div>

    </div>
  </div>
</div>
    </body>
</html>