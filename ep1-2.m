EPSILON = 2^(-30);

#compara raiz com raizes ja encontradas. se nao viu uma raiz nova, associa uma cor a ela. se a raiz nao existe (ou seja nao convergiu), associa a cor de nao convergencia
function [novasRaizes, indiceRaiz] = inclueRaiz(raiz, raizes, epsilon)
  len = length(raizes);
  indiceRaiz = 0;
  for cont = 1:len
    if (norm(raiz - raizes(cont)) <= 2*epsilon)
      indiceRaiz = cont;
      break
    endif
  end

  # se nao encontramos a raiz dentre as raizes conhecidas, copiamos o vetor de
  # raizes para um novo de tamanho maior e adicionamos a nova raiz
  if(indiceRaiz == 0)
    novasRaizes = zeros(1, len+1);
    for cont = 1:len
      novasRaizes(cont) = raizes(cont);
    end
    novasRaizes(len+1) = raiz;
    indiceRaiz = len + 1;
  # caso contrario, apenas devolvemos o vetor de raizes
  else
    novasRaizes = raizes;
  endif
endfunction

function raiz = newton(f, f_, x0, epsilon, max_iter)
    xprev = x0;
    raizComplex = nan;
#    raizVect = [0,0];
    #Aplica o metodo de newton, com condicao de parada fazer ao maximo 'max_iter' iteracoes
    for cont=1:max_iter

        #Condição de não convergência: f'(x) == 0, que implicaria em uma divisao por 0
        #resultado_f_ = f_(vectToComplex(xprev));
        resultado_f_ = f_(xprev);
        resultado_f = f(xprev);
        if (resultado_f_ == 0)
            break
        endif
        xnext = xprev - resultado_f/resultado_f_;
        nextV = complexToVec(xnext);
        prevV = complexToVec(xprev);
        dist = norm(nextV - prevV, 2); #Distancia euclidiana entre os dois pontos
        if (dist <= epsilon)
            #raizVect = xnext;
            raizComplex = xnext;
            break
        endif

        xprev = xnext;

    end
  raiz = raizComplex;
endfunction

function v = complexToVec(z)
    v = [real(z),z - real(z)];
endfunction

function z = vectToComplex(v)
    z = (v(1) + v(2)*i);
endfunction

function z = f1(x)
    #z = x^3 - 1;
    #z = x^2 + 1;
    #z = x^4 - 1;
    #z = x^7 - 1;
    z = x^10 - 4*x^7 + 3*x^3 -8*x -1;
endfunction

function z = f1_(x)
    #z = 3*(x^2);
    #z = 2*x;
    #z = 4*(x^3);
    #z = 7*(x^6);
    z = 10*x^9 - 28*x^6 + 9*x^2 -8;
endfunction

function writeOutput(resultados, raizes, temNan)
    filename = "output.txt";
    numRaizes = length(raizes) + temNan
    fid = fopen(filename, 'w');
    [p1, p2] = size(resultados);

    for cont1 = 1:p1
      for cont2 = 1:p2

        fprintf(fid, "%d %d %d\n", cont1-1, cont2-1, (1024/numRaizes)*resultados(cont1,cont2))

      end
    end

    fclose(fid);
endfunction

function newton_basins(f, f_, l, u, p, epsilon, max_iter)
  temNan = false;
  passoL = (l(2) - l(1))/p(1);
  passoU = (u(2) - u(1))/p(2);
  resultados = zeros(p(1), p(2));
  raizes = zeros(1, 0);
  for x = 1:p(1)
    for y = 1:p(2)
      argumento = (l(1) + (x-1)*passoL) + (u(1) + (y-1)*passoU)*i;
      resultados(x, y) = newton(f, f_, argumento, epsilon, max_iter);
      #disp('Fiz um newton :) :) :)')
      #disp(x)
      #disp(y)
      #disp(resultados(x, y))
      if isnan(resultados(x, y))
        resultados(x, y) = 0;
        temNan = true;
        #disp('Entrei no nan :( :* :)')
      else
        [raizes, resultados(x, y)] = inclueRaiz(resultados(x, y), raizes, epsilon);
      endif
    end
  end

  writeOutput(resultados, raizes, temNan)
  disp("acabou de achar bacias de convergencia")
endfunction

newton_basins(@f1, @f1_, [-2, 2], [-2, 2], [300, 300], EPSILON, 100)

#raiz = newton(@f1, @f1_, [1,1], EPSILON, 10000)
