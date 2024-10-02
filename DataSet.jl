using Distributions, LinearAlgebra, CSV, DataFrames, Statistics

# Define number of simulations
num_simulations = 100000

# Create normal distributions for amplitudes and phase angles
amp_dist = Normal(1, 0.05)
angle_a_dist = Normal(0, 5)
angle_b_dist = Normal(-120, 5)
angle_c_dist = Normal(120, 5)

# Pre-allocate matrix to store results [10000 rows, 12 columns]
results = zeros(num_simulations, 12)

# Define alpha for the transformation matrix
alpha = exp(im * 2 * π / 3)

# Transformation matrix to convert phase values into sequence components
transform_matrix = (1/3) * [1 1 1; 1 alpha conj(alpha); 1 conj(alpha) alpha]

# Run the simulation for 10000 times
for i in 1:num_simulations
    # Random amplitudes for phases a, b, and c
    V_a_amp = rand(amp_dist)
    V_b_amp = rand(amp_dist)
    V_c_amp = rand(amp_dist)

    # Random angles for phases a, b, and c (converted to radians)
    V_a_angle = rand(angle_a_dist) * π / 180
    V_b_angle = rand(angle_b_dist) * π / 180
    V_c_angle = rand(angle_c_dist) * π / 180

    # Complex voltages for phases a, b, and c
    V_a = V_a_amp * exp(im * V_a_angle)
    V_b = V_b_amp * exp(im * V_b_angle)
    V_c = V_c_amp * exp(im * V_c_angle)

    # Store amplitude and angle for phases a, b, and c
    results[i, 1] = V_a_amp  # Phase a amplitude
    results[i, 2] = V_b_amp  # Phase b amplitude
    results[i, 3] = V_c_amp  # Phase c amplitude
    results[i, 4] = V_a_angle * 180 / π  # Phase a angle in degrees
    results[i, 5] = V_b_angle * 180 / π  # Phase b angle in degrees
    results[i, 6] = V_c_angle * 180 / π  # Phase c angle in degrees

    # Voltage vector
    V_vector = [V_a; V_b; V_c]

    # Calculate sequence components
    sequences = transform_matrix * V_vector
    
    # Store real part of positive, negative, and zero sequences for amplitudes and angles
    results[i, 7] = abs(sequences[1])  # Zero sequence amplitude
    results[i, 8] = abs(sequences[2])  # Positive sequence amplitude
    results[i, 9] = abs(sequences[3])  # Negative sequence amplitude
    results[i, 10] = angle(sequences[1]) * 180 / π  # Zero sequence angle
    results[i, 11] = angle(sequences[2]) * 180 / π  # Positive sequence angle
    results[i, 12] = angle(sequences[3]) * 180 / π  # Negative sequence angle
end

# Create DataFrame
df = DataFrame(results, [:Phase_A_Amplitude, :Phase_B_Amplitude, :Phase_C_Amplitude, 
                         :Phase_A_Angle, :Phase_B_Angle, :Phase_C_Angle, 
                         :Zero_Amplitude, :Positive_Amplitude, :Negative_Amplitude, 
                         :Zero_Angle, :Positive_Angle, :Negative_Angle])

# Save results to a CSV file
CSV.write("phases_and_sequence_components_dataset.csv", df)

# Calculate and print mean and standard deviation for each column
for col in names(df)
    mean_val = mean(df[!, col])
    std_dev = std(df[!, col])
    println("$col - Mean: $mean_val, Std Dev: $std_dev")
end

println("Dataset generated, saved, and statistics calculated successfully.")
