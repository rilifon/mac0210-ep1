
#Configura nosso ep para poder ser usado
function config()

endfunction

#compara raiz com raizes ja encontradas. se nao viu uma raiz nova, associa uma cor a ela. se a raiz nao existe (ou seja nao convergiu), associa a cor de nao convergencia
function novasRaizes, indiceRaiz = inclueRaiz(raiz, raizes, epsilon)
  len = length(raizes);
  indiceRaiz = 0;
  for i = 1:len
    if novaRaiz && (norm(raiz - raizes(i)<= 2*epsilon)
      indiceRaiz = i;
    endif
  end
  if(indiceRaiz == 0)
    novasRaizes = zeros(1, len+1);
    for i = 1:len
      novasRaizes(i) = raizes(i);
    end
    novasRaizes(len+1) = raiz;
    indiceRaiz = i + 1;
  else
    novasRaizes = raizes;
  endif

endfunction

function newton(f, f_, x0, epsilon, max_iter)

    xprev = x0;
    raiz = nan;

    #Aplica o metodo de newton
    while(true)
        #Primeira condição de não convergência
        if (f_(xprev) == 0)
            break
        endif

        xnext = xprev - f(xprev)/f_(xprev);

    endwhile

endfunction

function newton_basins(f, f_, l, u, p, epsilon, max_iter)
  passoL = (l(2) - l(1))/p(1);
  passoU = (u(2) 0 u(1))/p(2);
  resultados = zeros(p(1), p(2));
  for i = 1:p(1)
    for j = 1:p(2)
      resultados(i, j) = newton(f, f_, )
    end
  end
endfunction
