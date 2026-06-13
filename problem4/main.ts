function sum_to_n_a(n: number): number {
    let sum = 0;
    if (n <= 0) {
        return 0;
    }
    for (let i = 1; i <= n; i++) {
        sum += i;
    }
    return sum;
}

function sum_to_n_b(n: number): number {
    if (n <= 0) {
        return 0;
    }

    if (n === 1) {
        return n;
    }
    return n + sum_to_n_b(n - 1);
}

function sum_to_n_c(n: number): number {
    if (n <= 0) {
        return 0;
    }
    return (n * (n + 1)) / 2;
}



let n;
// Test cases 1 input: 0
n = 0;
console.log(`Sum from 1 to ${n} using method A: ${sum_to_n_a(n)}`);
console.log(`Sum from 1 to ${n} using method B: ${sum_to_n_b(n)}`);
console.log(`Sum from 1 to ${n} using method C: ${sum_to_n_c(n)}`); 

// Test cases 2 input: 1
n = 1;
console.log(`Sum from 1 to ${n} using method A: ${sum_to_n_a(n)}`);
console.log(`Sum from 1 to ${n} using method B: ${sum_to_n_b(n)}`);
console.log(`Sum from 1 to ${n} using method C: ${sum_to_n_c(n)}`);

// Test cases 3 input: 5
n = 5;
console.log(`Sum from 1 to ${n} using method A: ${sum_to_n_a(n)}`);
console.log(`Sum from 1 to ${n} using method B: ${sum_to_n_b(n)}`);
console.log(`Sum from 1 to ${n} using method C: ${sum_to_n_c(n)}`);

// Test cases 4 input: 1000000
// With large n, method B will cause a stack overflow due to too much recursion, so we will not run it for n = 1000000
n = 1000000;
console.log(`Sum from 1 to ${n} using method A: ${sum_to_n_a(n)}`);
console.log(`Sum from 1 to ${n} using method B: ${sum_to_n_c(n)}`);
//console.log(`Sum from 1 to ${n} using method C: ${sum_to_n_b(n)}`);

// Test cases 5 input: -5
n = -5;
console.log(`Sum from 1 to ${n} using method A: ${sum_to_n_a(n)}`);
console.log(`Sum from 1 to ${n} using method B: ${sum_to_n_b(n)}`);
console.log(`Sum from 1 to ${n} using method C: ${sum_to_n_c(n)}`); 