$(document).ready(() => {
    const checkDoorAccessibility = async () => {
        try {
            const response = await fetch(`${window.accessControlUri}/api/v1/status`);
            if (!response.ok) {
                throw 'door control not ready';
            }
            $("#unlock-door").removeClass('disabled');
        } catch (e) {
            $("#unlock-door").addClass('disabled');
        }
    };

    // Poll if door control is available and update button state
    checkDoorAccessibility();
    setInterval(checkDoorAccessibility, 5000);

    $("#unlock-door").click(async () => {
        if ($("#unlock-door").hasClass('disabled')) {
            alert('Door control not accessible. Are you on the space Wi-Fi?');
            return;
        }

        try {
            // Fetch a short-lived token to authenticate with door control
            const tokenResponse = await fetch(`/members/users/${window.userId}/access_control_token`);
            if (!tokenResponse.ok) {
                throw 'failed to get door token';
            }
            const tokenJson = await tokenResponse.json();

            // Unlock the door
            const openResponse = await fetch(`${window.accessControlUri}/api/v1/unlock`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${tokenJson.token}`
                },
                body: JSON.stringify({
                    seconds: window.accessControlUnlockSeconds,
                }),
            });
            const openJson = await openResponse.json();
            if (!openResponse.ok) {
                throw openJson.message;
            }

            $("#unlock-error").addClass('hidden')
            $("#unlock-success").removeClass('hidden');

            // Hide the success message when the door should be locked again
            clearTimeout(window.successTimeoutId);
            window.successTimeoutId = setTimeout(() => {
                $("#unlock-success").addClass('hidden');
            }, window.accessControlUnlockSeconds * 1000);
        } catch (e) {
            $("#unlock-error").removeClass('hidden');
            $("#error-text").text(`Failed to unlock door: ${e}`);
        }
    });
});