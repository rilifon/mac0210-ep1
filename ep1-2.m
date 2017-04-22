EPSILON = 2^(-20);

#compara raiz com raizes ja encontradas. se nao viu uma raiz nova, associa uma cor a ela. se a raiz nao existe (ou seja nao convergiu), associa a cor de nao convergencia
function [novasRaizes, indiceRaiz] = inclueRaiz(raiz, raizes, epsilon)
  len = length(raizes);
  indiceRaiz = 0;
  for i = 1:len
    if novaRaiz && (norm(raiz - raizes(i)<= 2*epsilon))
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

function raiz = newton(f, f_, x0, epsilon, max_iter)
    xprev = x0;
    raiz = nan;
    #Aplica o metodo de newton, com condicao de parada fazer ao maximo 'max_iter' iteracoes
    for cont=1:max_iter

        #Condição de não convergência: f'(x) == 0, que implicaria em uma divisao por 0
        resultado_f_ = f_(vectToComplex(xprev));
        resultado_f = f(vectToComplex(xprev));
        if (resultado_f_ == 0)
            break
        endif

        xnext = xprev - complexToVec(resultado_f/resultado_f_);
        dist = norm(xnext - xprev, 2); #Distancia euclidiana entre os dois pontos
        if (dist <= epsilon)
            raiz = xnext;
            raiz = vectToComplex(raiz);
            break
        endif

        xprev = xnext;

    end

endfunction

function v = complexToVec(z)
    v = [real(z),z - real(z)];
endfunction

function z = vectToComplex(v)
    z = (v(1) + v(2)*i);
endfunction

function z = f1(x)
    z = x^2 + 1;
endfunction

function z = f1_(x)
    z = 2*x;
endfunction

raiz = newton(@f1, @f1_, [1,1], EPSILON, 10000)
