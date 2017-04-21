# subtrai num vetor em binario 'b' um bit na posição 'pos', retornando o resultado e se teve 'undercarry', ou seja,
# se vai precisar diminuir o expoente do valor original
function [b,carry] = subtraiBit(b, pos)
    carry = 1;
    i = pos;
    while (carry == 1 && i > 0)
        if b(i) == 0;
            b(i) = 1;
        else
            b(i) = 0;
            carry = 0;
        endif
        i = i - 1;
    endwhile
    # fazer certo aqui em baixo
    if (carry == 1)
        carry = -1;
    endif
endfunction

function n = binToDec(b, tam, exp)
	pot2 = 2^exp;
	i = 1;
	n = 0;
	while i <= tam
		n = n + pot2*b(i);
		pot2 = pot2 / 2;
		i = i + 1;
	endwhile
endfunction
	
# compara dois numeros no formato binario e devolve 0 se forem iguais,
# 1 se o primeiro for maior e 2 se o segundo for maior
function result = comparaNumero(n1, n2, tamanho)
	result = 0;
	i = 1
	while (result == 0 && i <= tamanho)
		if n1(i) != n2(i)
			if n1(i) > n2(i)
				result = 1
			else
				result = 2
			endif
		endif
		i = i + 1
	endwhile
endfunction

# soma num vetor em binario 'b' um bit na posição 'pos', retornando o resultado e se teve carry
function [b,carry] = somaBit(b, pos)
    carry = 1;
    i = pos;
    while (carry == 1 && i > 0)
        if b(i) == 0;
            b(i) = 1;
            carry = 0;
        else
            b(i) = 0;
        endif
        i = i - 1;
    endwhile
endfunction

# soma 1 no valor absoluto do numero
function [b, expoente] = somaULP(b, expoente)
    [b, carry] = somaBit(b,23)
    expoente += carry
endfunction


function bShift = shiftN(b, n)
	bShift = zeros(1, 26);
	if n >= 26
		n = 26;
		bShift(26) = 1;
	else
		i = 26 - n;
		while (i <= 23)
			if b(i) == 1
				bShift(26) = 1;
			endif
			i = i + 1;
		endwhile

		i = n + 1;
		while i <= 25
			if i - n <= 23
				bShift(i) = b(i - n);
			else
				bShift(i) = 0;
			endif
			i = i + 1;
		endwhile
		bShift(n) = 1;
	endif
endfunction


# realiza a soma ou subtracao de dois numeros positivos em floating point
# modo = 0 significa soma (b1 + b2)
# modo = 1 significa subtracao (b1 - b2)
function b = operaFloat(b1, b2, modo)
	carry = 0
	b = zeros(1, 26);
	menorShiftado = zeros(1, 26);

	# se o modo for subtracao, alteramos o sinal do segundo numero e realizamos uma soma
	if (modo == 1)
		b2(0) = (-1)*(b2(0) - 1)
	endif
	
	# vamos fazer com que b1 e b2 sejam tais que |b1| >= |b2|
	compExp = comparaNumero(b1(2:9), b2(2:9));
	if compExp == 0
		# os dois expoentes sao iguais, precisamos saber qual dos numeros tem
		# o maior modulo
		if comparaNumero(b1(10:32), b2(10:32)) == 2
			aux = b1;
			b1 = b2;
			b2 = aux;
		endif
	elseif compExp == 2
		aux = b1;
		b1 = b2;
		b2 = aux;
	endif

	maior = b1(10:32);
	difExpoente = b1(2:9);
	for i = 1:8
		if (b2(i+1) == 1)
			[difExpoente, lixo] = subtraiBit(difExpoente, i);
		endif
	end

	menorShiftado = shiftN(b2(10:32), binToDec(difExpoente))

	if exp1 >= exp2
		maior = b1;
		expMaior = exp1;
		menor = b2;
		expMenor = exp2;
	else
		maior = b2;
		expMaior = exp2;
		menor = b1;
		expMenor = exp1;
	endif

	# translada o menor numero para a direita
	shift = expMaior - expMenor
	if shift > 25
		shift = 25;
	endif

	i = 26 - shift;
	while (i <= 23)
		if menor(i) == 1
			menorShiftado(26) = 1;
		endif
		i = i + 1;
	endwhile

	i = shift + 1;
	while i <= 25
		menorShiftado(i) = menor(i - shift)
		i = i + 1;
	endwhile

	# copia o maior numero para o vetor onde sera realizada a soma
	for i = 1:23
		b(i) = maior(i);
	end

	# para cada 1 no menor numero, soma 1 na posicao devida
	carry = 0
	for i = 1:26
		if menorShiftado(i) == 1
			[b, carry] = somaBit(b, i);
		endif
	end

	expoente = expMaior;

	# caso haja carry, eh preciso normalizar novamente
	if carry == 1
		if b(25) == 1
			b(26) = 1;
		endif
		for i = i:24
			b(i+1) = b(i);
		end
		b(1) = 0;
		expoente = expoente + 1;
	endif

endfunction

# arredonda na direcao do +infinito
function [b, expoente] = roundUp(b, expoente, sinal)
	if sinal == 0
		[b, expoente] = somaULP(b(1:23), expoente);
	else
		b = b(1:23);
	endif
endfunction

# arredonda na direcao do -infinito
function [b, expoente] = roundDown(b, expoente, sinal)
	if sinal == 0
		b = b(1:23);
	else
		[b, expoente] = somaULP(b(1:23), expoente);
	endif
endfunction

# arredonda na direcao do zero
function [b, expoente] = roundToZero(b, expoente, sinal)
	# apenas trunca o numero, que equivale a chamar roundDown para um numero positivo
	# ou roundUp para um numero negativo
	b = b(1:23);
end

# arredonda para o numero mais perto
function [b, expoente] = roundToNearest(b, expoente, sinal)
	if b(24) == 0
		# o mais perto é o x-, ou seja, o valor mais perto de x em direção ao -infinito
		[b, expoente] = roundDown(b, expoente, sinal);
	elseif (b(25) == 1 || b(26) == 1)
		# o mais perto é o x+, ou seja, o valor mais perto de x em direção ao +infinito
		[b, expoente] = roundUp(b, expoente, sinal);
	else
		# empate, então pega aquele entre x- ou x+ que tenha o ultimo bit do significando == 0
		[a1, temp1] = roundDown(b, expoente, sinal);
		[a2, temp2] = roundUp(b, expoente, sinal);
		if a1(23) == 0
				#[b, expoente] = [a1, temp1];
				b = a1;
				expoente = temp1;
		else
				#[b, expoente] = [a2, temp2];
				b = a2;
				expoente = temp2;
		endif
	endif
endfunction

#
function [b, expoente] = converteBinario(n)
	b = zeros (1, 26);
	expoente = floor(log2(n));
	exptemp = 2^expoente;
	n = n - exptemp;

	# vamos iterar de 1 a 25, ou seja, os 23 bits do significando mais os dois
	# guard bits
	for i = 1:25
		exptemp = exptemp / 2;
		if n - exptemp >= 0
			n = n - exptemp;
			b(i) = 1;
		endif
	end
	if n > 0
		# esse eh o sticky bit
		b(26) = 1;
	endif
endfunction

# Recebe um numero no formato decimal e o converte para o formato da IEEE
function numIEEE = geraBin(n)
	numIEEE = zeros (1, 32);
	if (n < 0)
		numIEEE(1) = 1;
		n = n*-1;
	endif

	[b, expoente] = converteBinario(n);
	[b, expoente] = roundToNearest(b, expoente, numIEEE(1));
	expBin = expToBin(expoente);

	# armazena os bits do expoente no vetor que representa o numero
	for i = 1:8
		numIEEE(i+1) = expBin(i);
	end
	for i = 1:23
		numIEEE(i+9) = b(i);
	end
endfunction

# Recebe um expoente (de -126 a 127) e o converte para o formato binario do IEEE
function expBin = expToBin(x)
	x = x + 127;
	expBin = zeros(1, 8);
	while x > 0
		expoente = floor(log2(x));
		x = x - 2^expoente;
		# setamos o bit na posicao 9 - (expoente + 1) para que o vetor fique no
		# formato usual de numeros binarios
		expBin(9 - (expoente+1)) = 1;
	endwhile
endfunction

function n = floatToDec(b)
	expoente = 0;
	sinal = 1;

	sinal = sinal - 2*b(1);

	pot2 = 1;

	expoente = binToDec(b(2:9), 8, 7);
	expoente = expoente - 127;
	pot2 = 2^expoente;
	n = 2^expoente;
	n = n + binToDec(b(10:32), 23, expoente-1)
	n = n*sinal;

endfunction

function numDec = printBin (n)
	b = geraBin(n);
	b
	btemp = b(10:32)
	numDec = floatToDec(b);
	numDec
endfunction

# retorna a soma de decimais (a1 + a2)
function b = soma(a1, a2)
    b1 = geraBin(a1);
    b2 = geraBin(a2);
    b = somaFloat(b1, b2, 0);
end

# retorna a subtração de decimais (a1 - a2)
function b = subtrai(a1, a2)
    b1 = geraBin(a1);
    b2 = geraBin(a2);
    b = somaFloat(b1, b2, 1);
end

# compara a soma (a1 + a2) utilizando a operação '+' do octave com a nossa operação de soma.
# imprimi o resultado
function comparaSoma(a1,a2)
    b = soma(a1, a2);
    resultado = a1 + a2;
    resultadoIEEE = geraBin(resultado);
    igual = 1;
    for i = 1:32
        if b(i) != resultadoIEEE(i)
            igual = 0;
            break
        endif
    end
    if igual
        disp("O resultado da soma do octave foi igual ao da nossa soma!")
    else
        disp("O resultado da soma do octave foi diferente ao da nossa soma...")
    endif
endfunction

# compara a subtracao (a1 - a2) utilizando a operação '-' do octave com a nossa operação de soma.
# imprimi o resultado
function comparaSubtracao(a1,a2)
    b = subtrai(a1, a2);
    resultado = a1 - a2;
    resultadoIEEE = geraBin(resultado);
    igual = 1;
    for i = 1:32
        if b(i) != resultadoIEEE(i)
            igual = 0;
            break
        endif
    end
    if igual
        disp("O resultado da subtracao do octave foi igual ao da nossa subtracao!")
    else
        disp("O resultado da subtracao do octave foi diferente ao da nossa subtracao...")
    endif
endfunction
