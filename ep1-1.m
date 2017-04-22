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

function n = binToDec(b, tam, expoente)
	pot2 = 2^expoente;
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
	i = 1;
	while (result == 0 && i <= tamanho)
		if n1(i) != n2(i)
			if n1(i) > n2(i)
				result = 1;
			else
				result = 2;
			endif
		endif
		i = i + 1;
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
    [b, carry] = somaBit(b,23);
    expoente += carry;
endfunction


function bShift = shiftN(b, n)
	bShift = zeros(1, 26);
	if n <= 0
		for i = 1:23
			bShift(i) = b(i);
		end
	else		
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
	endif
endfunction


# realiza a soma ou subtracao de dois numeros positivos em floating point
# modo = 0 significa soma (b1 + b2)
# modo = 1 significa subtracao (b1 - b2)
function b = operaFloat(b1, b2, modo, rounding)
	carry = 0;
	b = zeros(1, 26);
	menorShiftado = zeros(1, 26);

	# se o modo for subtracao, alteramos o sinal do segundo numero e realizamos uma soma
	if (modo == 1)
		b2(1) = (-1)*(b2(1) - 1);
	endif
	
	# vamos fazer com que b1 e b2 sejam tais que |b1| >= |b2|
	compExp = comparaNumero(b1(2:9), b2(2:9), 8);
	if compExp == 0
		# os dois expoentes sao iguais, precisamos saber qual dos numeros tem
		# o maior modulo
		if comparaNumero(b1(10:32), b2(10:32), 23) == 2
			aux = b1;
			b1 = b2;
			b2 = aux;
		endif
	elseif compExp == 2
		aux = b1;
		b1 = b2;
		b2 = aux;
	endif

	difExpoente = b1(2:9);
	for i = 1:8
		if (b2(i+1) == 1)
			[difExpoente, lixo] = subtraiBit(difExpoente, i);
		endif
	end

	menorShiftado = shiftN(b2(10:32), binToDec(difExpoente, 8, 7));
	resultado = zeros(1, 26);
	for i = 1:23
		resultado(i) = b1(9 + i);
	end
	expoenteNovo = b1(2:9);

	# se os dois tiverem o mesmo sinal devemos fazer a soma dos modulos
	if (b1(1) == b2(1))
		for i = 1:26
			if menorShiftado(i) == 1
				[resultado, carryTemp] = somaBit(resultado, i);
				carry = carry + carryTemp;
			endif
		end
		if binToDec(difExpoente, 8, 7) == 0
			[expoenteNovo, lixo] = somaBit(expoenteNovo, 8);
			if (resultado(26) + resultado(25) > 0)
				resultado(26) = 1;
			else
				resultado(26) = 0;
			endif
			i = 24;
			while i >= 1
				resultado(i + 1) = resultado (i);
				i = i - 1;
			endwhile
			resultado(1) = 0;
		endif
	else
		for i = 1:26
			if menorShiftado(i) == 1
				[resultado, carryTemp] = subtraiBit(resultado, i);
				carry = carry + carryTemp;
			endif
		end
		if binToDec(difExpoente, 8, 7) == 0
			do
				hiddenBit = resultado(1);
				[expoenteNovo, lixo] = subtraiBit(expoenteNovo, 8);
				for i = 1:25
					resultado(i) = resultado(i + 1);
				end
				resultado(26) = 0;
			until hiddenBit == 1;
		endif
	endif

	if carry == 1
		[expoenteNovo, lixo] = somaBit(expoenteNovo, 8);
		if (resultado(26) + resultado(25) > 0)
			resultado(26) = 1;
		else
			resultado(26) = 0;
		endif
		i = 24;
		while i >= 1
			resultado(i + 1) = resultado (i);
			i = i - 1;
		endwhile
		resultado(1) = 0;

	elseif carry == -1
		do
			hiddenBit = resultado(1);
			[expoenteNovo, lixo] = subtraiBit(expoenteNovo, 8);
			for i = 1:25
				resultado(i) = resultado(i + 1);
			end
			resultado(26) = 0;
		until hiddenBit == 1;
	endif
	
	switch(rounding)
		case 1
			resultado = roundToNearest(resultado, binToDec(expoenteNovo, 8, 7), b1(1));
		case 2
			resultado = roundToZero(resultado, binToDec(expoenteNovo, 8, 7), b1(1));
		case 3
			resultado = roundUp(resultado, binToDec(expoenteNovo, 8, 7), b1(1));
		case 4
			resultado = roundDown(resultado, binToDec(expoenteNovo, 8, 7), b1(1));
	endswitch
	b = zeros(1, 32);
	b(1) = b1(1);
	for i = 1:8
		b(i + 1) = expoenteNovo(i);
	end
	for i = 1:23
		b(i + 9) = resultado(i);
	end

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
		# o mais perto de x eh em direção ao zero
		[b, expoente] = roundToZero(b, expoente, sinal);
	elseif (b(25) == 1 || b(26) == 1)
		# o mais perto é na direcao oposta ao 0, x+ caso seja positivo (arredondar em direcao a + infinito)
		# caso contrario, x- (arredondar em direcao a -infinito)
		if sinal == 0
			[b, expoente] = roundUp(b, expoente, sinal);
		else
			[b, expoente] = roundDown(b, expoente, sinal);
		endif
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
function numIEEE = geraBin(n, rounding)
	numIEEE = zeros (1, 32);
	if (n < 0)
		numIEEE(1) = 1;
		n = n*(-1);
	endif

	[b, expoente] = converteBinario(n)
	
	switch(rounding)
		case 1
			[b, expoente] = roundToNearest(b, expoente, numIEEE(1));
		case 2
			[b, expoente] = roundToZero(b, expoente, numIEEE(1));
		case 3
			[b, expoente] = roundUp(b, expoente, numIEEE(1));
		case 4
			[b, expoente] = roundDown(b, expoente, numIEEE(1));
	endswitch
	
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
	n = n + binToDec(b(10:32), 23, expoente-1);
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
function b = soma(a1, a2, rounding)
    b1 = geraBin(a1, rounding);
    b2 = geraBin(a2, rounding);
    b = operaFloat(b1, b2, 0, rounding);
end

# retorna a subtração de decimais (a1 - a2)
function b = subtrai(a1, a2, rounding)
    b1 = geraBin(a1, rounding);
    b2 = geraBin(a2, rounding);
    b = operaFloat(b1, b2, 1, rounding);
end

# compara a soma (a1 + a2) utilizando a operação '+' do octave com a nossa operação de soma.
# imprimi o resultado
function comparaSoma(a1,a2, rounding)
    disp("Começando uma soma")
    imprimiRound(rounding)
    a1
    a2
    resultadoObtidoIEEE = soma(a1, a2, rounding);
    resultadoEsperado = a1 + a2
    resultadoEsperadoIEEE = geraBin(resultadoEsperado, rounding);
    igual = 1;
    for i = 1:32
        if resultadoObtidoIEEE(i) != resultadoEsperadoIEEE(i)
            igual = 0;
            break
        endif
    end
    resultadoEsperadoIEEE
    resultadoObtidoIEEE
    resultadoObtido = floatToDec(resultadoObtidoIEEE)
    if igual
        disp("O resultado da soma do octave foi igual ao da nossa soma!")
    	disp("---------------------------------------------------------")
    else
        disp("O resultado da soma do octave foi diferente ao da nossa soma...")
       	disp("---------------------------------------------------------")
    endif
endfunction

# compara a subtracao (a1 - a2) utilizando a operação '-' do octave com a nossa operação de soma.
# imprimi o resultado
function comparaSubtracao(a1,a2, rounding)
    disp("Começando uma subtracao")
    imprimiRound(rounding)
    a1
    a2
    resultadoObtidoIEEE = subtrai(a1, a2, rounding);
    resultadoEsperado = a1 - a2
    resultadoEsperadoIEEE = geraBin(resultadoEsperado, rounding);
    igual = 1;
    for i = 1:32
        if resultadoObtidoIEEE(i) != resultadoEsperadoIEEE(i)
            igual = 0;
            break
        endif
    end
    resultadoEsperadoIEEE
    resultadoObtidoIEEE
    resultadoObtido = floatToDec(resultadoObtidoIEEE)
    if igual
        disp("O resultado da subtracao do octave foi igual ao da nossa soma!")
    	disp("---------------------------------------------------------")
    else
        disp("O resultado da subtracao do octave foi diferente ao da nossa soma...")
       	disp("---------------------------------------------------------")
    endif
endfunction

function imprimiRound(rounding)
	
	switch(rounding)

		case 1
			disp("Utilizando arredondamento: roundToNearest")
		case 2
			disp("Utilizando arredondamento: roundToZero")
		case 3
			disp("Utilizando arredondamento: roundUp")
		case 4
			disp("Utilizando arredondamento: roundDown")
	endswitch

endfunction

comparaSoma(2, 3, 1);
comparaSoma(1, 2^(-24), 1);
comparaSubtracao(1, (1 - 2^(-24)), 1)
comparaSubtracao(1, (2^(-25) + 2^(-48)), 1)