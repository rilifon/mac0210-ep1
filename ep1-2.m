
#Configura nosso ep para poder ser usado
function config()

endfunction

#compara raiz com raizes ja encontradas. se nao viu uma raiz nova, associa uma cor a ela. se a raiz nao existe (ou seja nao convergiu), associa a cor de nao convergencia
function novasRaizes = inclueRaiz(raiz, raizes, epsilon)
  len = length(raizes);
  novaRaiz = true;
  for i = 1:len
    if novaRaiz && (raiz <= raizes(i)+epsilon) && (raiz <= raizes(i)-epsilon)
      novaRaiz = false;
    endif
  end
  if(novaRaiz)
    novasRaizes = zeros(1, len+1);
    for i = 1:len
      novasRaizes(i) = raizes(i);
    end
    novasRaizes(len+1) = raiz;
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
